"""A label on a ledger entry."""


class Label:
    def __init__(self, text: str) -> None:
        self.text = text

    def get_text(self) -> str:
        return self.text

    def set_text(self, text: str) -> None:
        self.text = text
