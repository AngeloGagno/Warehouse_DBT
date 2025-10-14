from decimal import Decimal, ROUND_HALF_UP


def money(val: float, places: int = 2) -> Decimal:
    """Arredonda com 2 casas decimais (estilo moeda)."""
    q = Decimal(10) ** -places
    return Decimal(val).quantize(q, rounding=ROUND_HALF_UP)