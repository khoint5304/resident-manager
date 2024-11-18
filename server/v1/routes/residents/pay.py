from __future__ import annotations

import hashlib
import hmac
import urllib.parse
from datetime import datetime, timedelta, timezone
from typing import Dict, Union

from yarl import URL
from fastapi import HTTPException, Request, status
from fastapi.responses import RedirectResponse

from ...app import api_v1
from ...models import Fee, Room
from ....config import VNPAY_SECRET_KEY, VNPAY_TMN_CODE


__all__ = ("residents_pay",)
_BASE = URL("https://sandbox.vnpayment.vn/paymentv2/vpcpay.html")


def _format_time(time: datetime) -> str:
    return time.strftime("%Y%m%d%H%M%S")


@api_v1.get(
    "/residents/pay",
    name="Fee payment",
    description="Perform a payment for a fee",
    tags=["resident"],
)
async def residents_pay(
    request: Request,
    room: int,
    fee_id: int,
    amount: float,
) -> RedirectResponse:
    fees = await Fee.query(offset=0, id=fee_id)
    if len(fees) == 0:
        raise HTTPException(status.HTTP_404_NOT_FOUND)

    fee = fees[0]
    rooms = await Room.query(offset=0, room=room)
    if len(rooms) == 0:
        raise HTTPException(status.HTTP_404_NOT_FOUND)

    r = rooms[0]
    if r.area is None or r.motorbike is None or r.car is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST)

    extra = fee.per_area * r.area + fee.per_motorbike * r.motorbike + fee.per_car * r.car
    if amount < fee.lower + extra or amount > fee.upper + extra:
        raise HTTPException(status.HTTP_400_BAD_REQUEST)

    # Construct VNPay URL
    now = datetime.now(timezone(timedelta(hours=7)))
    expire = now + timedelta(hours=1)

    params: Dict[str, Union[int, str]] = {
        "vnp_Version": "2.1.0",
        "vnp_Command": "pay",
        "vnp_TmnCode": VNPAY_TMN_CODE,
        "vnp_Amount": int(100 * amount),
        "vnp_CreateDate": _format_time(now),
        "vnp_CurrCode": "VND",
        "vnp_IpAddr": request.headers["x-client-ip"],  # Azure headers containing client IP address
        "vnp_Locale": "vn",
        "vnp_OrderInfo": f"Thanh toan {room} cho {fee_id}",
        "vnp_OrderType": 250000,
        "vnp_ReturnUrl": "https://example.com",
        "vnp_ExpireDate": _format_time(expire),
        "vnp_TxnRef": f"{room}-{fee_id}-{amount}",
    }
    params = dict(sorted(params.items()))

    data = "&".join(f"{k}={urllib.parse.quote_plus(str(v))}" for k, v in params.items())
    params["vnp_SecureHash"] = hmac.new(
        VNPAY_SECRET_KEY.encode("utf-8"),
        data.encode("utf-8"),
        digestmod=hashlib.sha512,
    ).hexdigest()

    url = _BASE.with_query(params)
    return RedirectResponse(str(url))
