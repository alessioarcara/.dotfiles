import random
import time

from ledger.jobs import Job


def slow_double():
    time.sleep(random.uniform(0.0, 0.03))
    return 21 * 2


def test_a_job_returns_the_result_of_its_work() -> None:
    job = Job(slow_double)

    job.start()
    time.sleep(0.01)

    assert job.result() == 42
