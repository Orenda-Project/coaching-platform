"""Admin management service for user administration and issue tracking."""

from sqlalchemy import select, func
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Optional, List, Tuple
from datetime import datetime
import uuid

from app.models.admin import AdminUser, AdminRole, FieldIssue, FieldIssueStatus, Region
from app.models.user import User


class AdminService:
    """Service for admin management operations."""

    def __init__(self, db: Session):
        self.db = db

    # ===== ADMIN USER MANAGEMENT =====

    def create_admin_user(self, user_id: str, role: str = "super_admin") -> Optional[AdminUser]:
        """
        Create an admin user record.

        Args:
            user_id: UUID from users table
            role: Admin role (super_admin, regional_admin)

        Returns:
            Created AdminUser or None if error
        """
        try:
            # Validate role
            valid_roles = {AdminRole.SUPER_ADMIN.value, AdminRole.REGIONAL_ADMIN.value}
            if role not in valid_roles:
                return None

            admin_id = str(uuid.uuid4())
            admin_user = AdminUser(
                id=admin_id,
                user_id=user_id,
                role=role,
            )
            self.db.add(admin_user)
            self.db.commit()
            self.db.refresh(admin_user)
            return admin_user
        except IntegrityError:
            self.db.rollback()
            return None

    def get_admin_user_by_id(self, admin_id: str) -> Optional[AdminUser]:
        """Get admin user by admin ID."""
        return self.db.execute(
            select(AdminUser).filter(AdminUser.id == admin_id)
        ).scalar_one_or_none()

    def get_admin_user_by_user_id(self, user_id: str) -> Optional[AdminUser]:
        """Get admin user by user ID."""
        return self.db.execute(
            select(AdminUser).filter(AdminUser.user_id == user_id)
        ).scalar_one_or_none()

    def get_all_admin_users(self, limit: int = 100, offset: int = 0) -> Tuple[List[AdminUser], int]:
        """
        List all admin users with pagination.

        Args:
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (admin users list, total count)
        """
        total = self.db.execute(
            select(func.count(AdminUser.id))
        ).scalar() or 0

        admins = self.db.execute(
            select(AdminUser).limit(limit).offset(offset)
        ).scalars().all()

        return list(admins), total

    def update_admin_user_role(self, admin_id: str, new_role: str) -> Optional[AdminUser]:
        """
        Update admin user role.

        Args:
            admin_id: Admin ID
            new_role: New role value

        Returns:
            Updated AdminUser or None if not found/invalid
        """
        admin_user = self.get_admin_user_by_id(admin_id)
        if not admin_user:
            return None

        valid_roles = {AdminRole.SUPER_ADMIN.value, AdminRole.REGIONAL_ADMIN.value}
        if new_role not in valid_roles:
            return None

        admin_user.role = new_role
        try:
            self.db.commit()
            self.db.refresh(admin_user)
            return admin_user
        except Exception:
            self.db.rollback()
            return None

    def delete_admin_user(self, admin_id: str) -> bool:
        """
        Delete admin user record.

        Args:
            admin_id: Admin ID

        Returns:
            True if deleted, False if not found
        """
        admin_user = self.get_admin_user_by_id(admin_id)
        if not admin_user:
            return False

        try:
            self.db.delete(admin_user)
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False

    # ===== FIELD ISSUE MANAGEMENT =====

    def create_field_issue(
        self,
        description: str,
        reported_by: str,
        assigned_to: Optional[str] = None
    ) -> Optional[FieldIssue]:
        """
        Create a new field issue.

        Args:
            description: Issue description
            reported_by: User ID of reporter
            assigned_to: User ID of assignee (optional)

        Returns:
            Created FieldIssue or None if error
        """
        try:
            issue_id = str(uuid.uuid4())
            issue = FieldIssue(
                id=issue_id,
                description=description,
                reported_by=reported_by,
                assigned_to=assigned_to,
                status=FieldIssueStatus.OPEN.value,
            )
            self.db.add(issue)
            self.db.commit()
            self.db.refresh(issue)
            return issue
        except IntegrityError:
            self.db.rollback()
            return None

    def get_field_issue_by_id(self, issue_id: str) -> Optional[FieldIssue]:
        """Get field issue by ID."""
        return self.db.execute(
            select(FieldIssue).filter(FieldIssue.id == issue_id)
        ).scalar_one_or_none()

    def get_all_field_issues(
        self,
        status: Optional[str] = None,
        limit: int = 100,
        offset: int = 0
    ) -> Tuple[List[FieldIssue], int]:
        """
        List field issues with optional status filter.

        Args:
            status: Optional status filter
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (issues list, total count)
        """
        query = select(FieldIssue)
        if status:
            query = query.filter(FieldIssue.status == status)

        total = self.db.execute(
            select(func.count(FieldIssue.id)).select_from(FieldIssue)
            if not status
            else select(func.count(FieldIssue.id)).select_from(FieldIssue).filter(FieldIssue.status == status)
        ).scalar() or 0

        issues = self.db.execute(
            query.limit(limit).offset(offset)
        ).scalars().all()

        return list(issues), total

    def update_field_issue(
        self,
        issue_id: str,
        **kwargs
    ) -> Optional[FieldIssue]:
        """
        Update field issue.

        Args:
            issue_id: Issue ID
            **kwargs: Fields to update (description, status, assigned_to)

        Returns:
            Updated FieldIssue or None if not found
        """
        issue = self.get_field_issue_by_id(issue_id)
        if not issue:
            return None

        allowed_fields = {"description", "status", "assigned_to"}
        for key, value in kwargs.items():
            if key in allowed_fields:
                if key == "status":
                    # Mark resolved_at if status is resolved/closed
                    valid_statuses = {
                        FieldIssueStatus.OPEN.value,
                        FieldIssueStatus.IN_PROGRESS.value,
                        FieldIssueStatus.RESOLVED.value,
                        FieldIssueStatus.CLOSED.value,
                    }
                    if value not in valid_statuses:
                        return None
                    if value in {FieldIssueStatus.RESOLVED.value, FieldIssueStatus.CLOSED.value}:
                        issue.resolved_at = datetime.utcnow()
                setattr(issue, key, value)

        try:
            self.db.commit()
            self.db.refresh(issue)
            return issue
        except Exception:
            self.db.rollback()
            return None

    def delete_field_issue(self, issue_id: str) -> bool:
        """
        Delete field issue.

        Args:
            issue_id: Issue ID

        Returns:
            True if deleted, False if not found
        """
        issue = self.get_field_issue_by_id(issue_id)
        if not issue:
            return False

        try:
            self.db.delete(issue)
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False

    # ===== REGION MANAGEMENT =====

    def create_region(
        self,
        name: str,
        parent_id: Optional[str] = None
    ) -> Optional[Region]:
        """
        Create a new region.

        Args:
            name: Region name
            parent_id: Parent region ID (optional)

        Returns:
            Created Region or None if error
        """
        try:
            region_id = str(uuid.uuid4())
            region = Region(
                id=region_id,
                name=name,
                parent_id=parent_id,
                is_active=True,
            )
            self.db.add(region)
            self.db.commit()
            self.db.refresh(region)
            return region
        except IntegrityError:
            self.db.rollback()
            return None

    def get_region_by_id(self, region_id: str) -> Optional[Region]:
        """Get region by ID."""
        return self.db.execute(
            select(Region).filter(Region.id == region_id)
        ).scalar_one_or_none()

    def get_region_by_name(self, name: str) -> Optional[Region]:
        """Get region by name."""
        return self.db.execute(
            select(Region).filter(Region.name == name)
        ).scalar_one_or_none()

    def get_all_regions(
        self,
        active_only: bool = False,
        limit: int = 100,
        offset: int = 0
    ) -> Tuple[List[Region], int]:
        """
        List regions with optional filtering.

        Args:
            active_only: Filter to active regions only
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (regions list, total count)
        """
        query = select(Region)
        if active_only:
            query = query.filter(Region.is_active == True)

        total = self.db.execute(
            select(func.count(Region.id)).select_from(Region)
            if not active_only
            else select(func.count(Region.id)).select_from(Region).filter(Region.is_active == True)
        ).scalar() or 0

        regions = self.db.execute(
            query.limit(limit).offset(offset)
        ).scalars().all()

        return list(regions), total

    def update_region(
        self,
        region_id: str,
        **kwargs
    ) -> Optional[Region]:
        """
        Update region.

        Args:
            region_id: Region ID
            **kwargs: Fields to update (name, parent_id, is_active)

        Returns:
            Updated Region or None if not found
        """
        region = self.get_region_by_id(region_id)
        if not region:
            return None

        allowed_fields = {"name", "parent_id", "is_active"}
        for key, value in kwargs.items():
            if key in allowed_fields:
                setattr(region, key, value)

        try:
            self.db.commit()
            self.db.refresh(region)
            return region
        except IntegrityError:
            self.db.rollback()
            return None

    def delete_region(self, region_id: str) -> bool:
        """
        Delete region.

        Args:
            region_id: Region ID

        Returns:
            True if deleted, False if not found
        """
        region = self.get_region_by_id(region_id)
        if not region:
            return False

        try:
            self.db.delete(region)
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False
