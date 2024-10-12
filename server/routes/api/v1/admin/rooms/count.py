from __future__ import annotations

from typing import Optional

from fastapi import Response, status

from ......apps import api_v1
from ......models import Authorization, AuthorizationHeader, Result, Room


__all__ = ("admin_rooms_count",)


@api_v1.get(
    "/admin/rooms/count",
    name="Rooms count",
    description="Return number of rooms",
    tags=["admin"],
    responses={
        status.HTTP_200_OK: {
            "description": "Return number of rooms",
            "model": Result[int],
        },
        status.HTTP_400_BAD_REQUEST: {
            "description": "Incorrect authorization data",
            "model": Result[None],
        },
    },
)
async def admin_rooms_count(
    headers: AuthorizationHeader,
    response: Response,
    room: Optional[int] = None,
    floor: Optional[int] = None,
) -> Result[Optional[int]]:
    auth = await Authorization.verify_admin_headers(headers)
    if auth is not None:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return auth

    return Result(data=await Room.count(room=room, floor=floor))
