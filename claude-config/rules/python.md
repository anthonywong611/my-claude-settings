# Python Rules

## Type system
- All function signatures must have type hints (args + return type)
- Use `from __future__ import annotations` for forward references
- Prefer `dataclasses.dataclass` or `pydantic.BaseModel` for structured data — never plain dicts as contracts
- Use `TypedDict` for dict shapes that must cross function boundaries

## Error handling
- Never use bare `except:` — always catch a specific exception class
- Re-raise with context: `raise ValueError("...") from original_exc`
- Log errors before raising in library code; let application code decide what to surface

## Imports
- `stdlib` → `third-party` → `local`, separated by blank lines
- No wildcard imports (`from module import *`)
- Absolute imports only inside packages

## Naming
- `snake_case` for variables, functions, modules
- `PascalCase` for classes
- `SCREAMING_SNAKE_CASE` for module-level constants
- Prefix private helpers with `_`

## Testing
- Every public function must have at least one test
- Use `pytest.fixture` for shared state — never `setUp/tearDown`
- Mock external calls (GCS, BQ, APIs) with `unittest.mock.patch`
- Aim for 80%+ branch coverage on core transform logic
