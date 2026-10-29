"""python -m ledger as a subprocess."""

import subprocess
import sys


def run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run([sys.executable, "-m", "ledger", *args], capture_output=True, text=True)


def test_a_comma_decimal_is_accepted() -> None:
    assert run("1,50").stdout.strip() == "1.50"


def test_whitespace_around_a_price_is_ignored() -> None:
    assert run(" 2 ").stdout.strip() == "2.00"


def test_a_negative_price_is_rejected() -> None:
    result = run("-3")

    assert result.returncode == 2
    assert "must not be negative" in result.stderr


def test_text_that_is_not_a_number_is_rejected() -> None:
    result = run("abc")

    assert result.returncode == 2
    assert "not a price" in result.stderr


def test_a_half_cent_rounds_to_the_even_cent() -> None:
    assert run("2.675").stdout.strip() == "2.68"
    assert run("2.665").stdout.strip() == "2.66"


def test_the_total_of_several_prices_is_printed() -> None:
    assert run("1,50", "2", "3.25").stdout.strip() == "6.75"
