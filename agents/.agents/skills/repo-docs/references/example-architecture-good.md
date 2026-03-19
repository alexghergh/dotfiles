# ARCHITECTURE Good Example

## Traits

- names the major components and their responsibilities
- explains the main request, job, or data flow
- documents important contracts and boundaries
- uses diagrams only when they add clarity
- stays aligned with the current codebase

## Example skeleton

```md
# architecture

## major components
- `api/` handles request validation and transport
- `domain/` owns business rules
- `infra/` handles persistence and external services

## request flow
1. request enters `api/`
2. validated data moves into `domain/`
3. `infra/` persists results and publishes side effects

## key contracts
- domain code does not call HTTP helpers directly
- infra adapters implement the storage interfaces
```
