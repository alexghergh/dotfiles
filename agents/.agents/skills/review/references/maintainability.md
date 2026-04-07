# Maintainability

Evaluate how easy the code is to understand, modify, and extend.

## What to look for

- module boundaries and coupling between components
- depth of nesting and control flow complexity
- consistent error handling patterns
- testability (can components be tested in isolation?)
- changeability (can one feature be modified without ripple effects?)
- appropriate use of abstractions (not too early, not too late)

## Reviewer stance

- prioritize simple structure changes before broad refactors
- avoid proposing rewrites where a localized change fixes the concrete risk
- prefer changes that reduce coupling and preserve straightforward local reasoning
- call out maintainability risks that can predictably make future changes more expensive or error-prone

## Examples

Good:
- clear module boundaries with narrow interfaces
- functions that do one thing and are easy to follow
- changes to one feature stay localized to a few files

Bad:
- god class or function that handles multiple unrelated concerns
- circular dependencies between modules
- modifying a simple feature requires changes in 10+ files

## Grading

- **5**: Code is a pleasure to modify; clear boundaries, minimal coupling
- **4**: Mostly well-structured; minor coupling or complexity issues
- **3**: Some areas are tangled or hard to change safely
- **2**: Significant structural problems that make changes risky
- **1**: Deeply entangled code where any change risks breaking unrelated features
