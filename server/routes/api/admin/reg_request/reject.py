from __future__ import annotations

from typing import Annotated, List

from fastapi import HTTPException, Header, status

from .....database import Database
from .....models import Authorization, RegisterRequest
from .....routers import api_router


@api_router.post(
    "/admin/reg-request/reject",
    name="Registration requests rejection",
    description="Reject one or more registration requests",
    tags=["admin"],
    response_model=None,
    responses={status.HTTP_401_UNAUTHORIZED: {}},
    status_code=status.HTTP_204_NO_CONTENT,
)
async def admin_reg_request_reject(ids: List[int], headers: Annotated[Authorization, Header()]) -> None:
    if not await Database.instance.verify_admin(headers.username, headers.password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    await RegisterRequest.reject_many(ids)