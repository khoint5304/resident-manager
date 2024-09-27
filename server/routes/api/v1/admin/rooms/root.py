from __future__ import annotations

from typing import Annotated, List, Optional

from fastapi import Header, status

from ......apps import api_v1
from ......config import DB_PAGINATION_QUERY
from ......database import Database
from ......models import Authorization, Room


@api_v1.get(
    "/admin/rooms",
    name="Room information query",
    description=f"Query a maximum of {DB_PAGINATION_QUERY} room information from the specified offset",
    tags=["admin"],
    responses={status.HTTP_401_UNAUTHORIZED: {}, status.HTTP_403_FORBIDDEN: {}},
    status_code=status.HTTP_200_OK,
)
async def admin_rooms(
    offset: int,
    headers: Annotated[Authorization, Header()],
    room: Optional[int] = None,
    floor: Optional[int] = None,
) -> List[Room]:
    await Database.instance.verify_admin(headers.username, headers.decrypt_password())
    return await Room.query(offset=offset, room=room, floor=floor)