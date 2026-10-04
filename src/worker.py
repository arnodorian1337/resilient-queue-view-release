from dataclasses import dataclass

@dataclass(frozen=True)
class QueueJob:
    identifier: str
    attempts: int = 0
