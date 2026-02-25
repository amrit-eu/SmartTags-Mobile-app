# Error Handling Patterns for Flutter Screens

This document outlines general error handling approaches that have been used for Flutter screens and forms. These patterns are intended to provide consistency and clarity for future development.

## 1. Form Validation

- **Validation on Submit:**  
   User input fields should be validated when the form is submitted. Use a `Form` widget with a `GlobalKey` to manage validation state.
- **Field Validators:**  
  Each input field should use a `validator` function to check for error states such as:
  - Required fields (non-empty input)
  - Correct data types (e.g., numeric, date)
  - Valid value ranges (where applicable)
- **Error Messages:**  
  If validation fails, display a descriptive and user friendly error message directly below the relevant input field.

## 2. User Feedback with SnackBars

- **Success Feedback:**  
  When an operation completes successfully, show a `SnackBar` to inform the user.
- **Error Feedback:**  
  If an error occurs during an operation (e.g., database failure, network error, service issues), display a `SnackBar` with a relevant user friendly error message.
- **Service Updates:**  
  Use `SnackBar` notifications to inform users of changes in service status or background operations.

## 3. Exception Handling

- **Try-Catch Blocks:**  
  Wrap operations that may fail (such as database or network calls) in `try-catch` blocks. On exception, log the error with `debugPrint` and notify the user via a `SnackBar` if it is important.
- **Mounted Checks:**  
  Before updating UI state or showing a `SnackBar` after an asynchronous operation, check if the widget is still mounted.

## 4. Consistency Guidelines

- Use `Form` and field-level `validator` functions for all user input.
- Display validation errors inline, close to the relevant field. (This is a feature of the `validator`.)
- Use `SnackBar` for asynchronous operation feedback (success or failure).
- Check `mounted` before updating UI or showing a `SnackBar` after an async operation.
- Log errors for debugging using `debugPrint`, but show user-friendly messages in the UI.

---
