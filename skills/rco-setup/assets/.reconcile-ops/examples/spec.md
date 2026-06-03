<!-- Example only: this file uses todo CRUD behavior as sample content. Reference the structure only. -->

# Spec: Todo Item CRUD

## Source Documents

- [Basic Todo Management](../../docs/goals/G-000001.md)
- [Todo Web App](../../docs/requirements/todo-web-app.md)

## Purpose

Define the baseline design for todo item creation, completion, and deletion before implementation. This spec focuses on the code-level design needed to support item entry, state transitions, removal, and user-facing feedback.

## Behavior

- A user submits a short title to create a new todo item.
- The system validates that the title is non-empty before persisting the item.
- A user can mark an existing todo item as completed.
- A user can delete an existing todo item.
- Deleted items are removed from the active list.

## Boundaries

- The todo CRUD flow owns item creation, completion toggling, deletion, and in-memory or persisted storage.
- The todo CRUD flow does not own user accounts, team sharing, due dates, reminders, or calendar integration.

## Interfaces

- `POST /todos`
  - Input: title string.
  - Success: created todo item with generated id.
  - Failure: validation error when title is empty.
- `PATCH /todos/{id}`
  - Input: completed boolean.
  - Success: updated todo item.
  - Failure: not-found error when id does not exist.
- `DELETE /todos/{id}`
  - Success: confirmation of deletion.
  - Failure: not-found error when id does not exist.

## Data Contracts

- Todo item requires a non-empty title string.
- Todo item has a generated unique id, a completed boolean defaulting to false, and a created-at timestamp.
- Completed and deleted states are mutually exclusive: an item cannot be completed and deleted simultaneously.

## Validation Rules

- Title is required and must not be empty or whitespace-only.
- Toggle and delete operations require a valid existing item id.

## Error Handling

- Empty title shows a validation error.
- Operations on non-existent item ids return a not-found error.
- Unexpected persistence errors return a safe generic error and should be observable by application logging.

## Verification Approach

- Verify empty title produces a validation error.
- Verify creating an item with a valid title persists the item.
- Verify toggling completed changes the item state.
- Verify deleting an item removes it from the active list.
- Verify operations on non-existent ids return not-found errors.
