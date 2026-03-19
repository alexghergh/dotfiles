# Maintainability

Evaluate how easy the code is to understand, modify, and extend.

## What to look for

- Module boundaries and coupling between components
- Depth of nesting and control flow complexity
- Consistent error handling patterns
- Testability (can components be tested in isolation?)
- Changeability (can one feature be modified without ripple effects?)
- Appropriate use of abstractions (not too early, not too late)

## Examples

Good (4-5):
- Clear module boundaries with narrow interfaces
- Functions that do one thing and are easy to follow
- Changes to one feature stay localized to a few files

Bad (1-2):
- God class or function that handles multiple unrelated concerns
- Circular dependencies between modules
- Modifying a simple feature requires changes in 10+ files

## Grading

- **5**: Code is a pleasure to modify; clear boundaries, minimal coupling
- **4**: Mostly well-structured; minor coupling or complexity issues
- **3**: Some areas are tangled or hard to change safely
- **2**: Significant structural problems that make changes risky
- **1**: Deeply entangled code where any change risks breaking unrelated features
