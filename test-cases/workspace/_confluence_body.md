## Test Case Table (Excel format)

| Scenario ID | Tags | Scenario | Description |
| --- | --- | --- | --- |
| TC_CONWORK_001 | @ui @positive @smoke | Widget displays in-progress document card with all required fields | Given a user has a document with saved state in Draft status  
When they load Workspace  
Then the Continue Work widget displays it as a card  
And the card shows document type, entity/workflow name, a status badge, a description line, and "Last edited by [name], [date/time]" |
| TC_CONWORK_002 | @ui @positive | Widget displays card for document in Needs Signature status | Given a user has a document with saved state in Needs Signature status  
When they load Workspace  
Then the Continue Work widget displays it as a card  
And the status badge reads Needs Signature |
| TC_CONWORK_003 | @ui @positive | Widget displays card for document in Payment Pending status | Given a user has a document with saved state in Payment Pending status  
When they load Workspace  
Then the Continue Work widget displays it as a card  
And the status badge reads Payment Pending |
| TC_CONWORK_004 | @ui @positive | Widget displays card for document in Awaiting ASIC status | Given a user has a document with saved state in Awaiting ASIC status  
When they load Workspace  
Then the Continue Work widget displays it as a card  
And the status badge reads Awaiting ASIC |
| TC_CONWORK_005 | @ui @positive @smoke | Cards are sorted most-recently-updated first | Given a user has multiple in-progress documents and workflows with different last-updated timestamps  
When they load Workspace  
Then the Continue Work widget displays the cards ordered from most-recently-updated to least-recently-updated |
| TC_CONWORK_006 | @ui @positive | Card ordering updates after editing an older item | Given a user has multiple in-progress documents displayed in the Continue Work widget  
When they resume and save further edits to a document that was not the most recently updated  
And they reload Workspace  
Then that document's card moves to the top of the list as the most-recently-updated item |
| TC_CONWORK_007 | @ui @positive @smoke | Empty state displays when there are zero in-progress items | Given a user has zero in-progress documents or workflows  
When the Continue Work widget renders  
Then an empty state displays with heading "Continue Work"  
And message "No work to continue yet"  
And subtext "Drafts and in-progress documents will appear here once you've started working on them"  
And a "Create a new document" CTA button is displayed |
| TC_CONWORK_008 | @ui @positive @smoke | Create a new document CTA navigates to documents/forms list | Given the empty state is displayed in the Continue Work widget  
When the user clicks "Create a new document"  
Then they are navigated to the original documents/forms list |
| TC_CONWORK_009 | @ui @accessibility @positive | Create a new document CTA is keyboard operable | Given the empty state is displayed in the Continue Work widget  
When the user tabs to focus the "Create a new document" button  
And presses Enter  
Then they are navigated to the original documents/forms list |
| TC_CONWORK_010 | @ui @positive | Drag handle and feedback icons appear on hover | Given the widget is in its default state  
When the user hovers over a document card  
Then the drag handle becomes visible  
And the thumbs-up and thumbs-down icons become visible |
| TC_CONWORK_011 | @ui @accessibility @positive | Drag handle and feedback icons appear on keyboard focus | Given the widget is in its default state  
When the user tabs to keyboard-focus a document card  
Then the drag handle becomes visible  
And the thumbs-up and thumbs-down icons become visible |
| TC_CONWORK_012 | @ui @edge @positive | Drag handle and feedback icons hide when hover/focus ends | Given the drag handle and feedback icons are visible on a hovered card  
When the user moves the pointer away from the card and no card is keyboard-focused  
Then the drag handle and thumbs-up/thumbs-down icons return to hidden |
| TC_CONWORK_013 | @ui @edge @positive | Scrollbar appears on hover when card content overflows | Given the widget contains enough cards that content overflows the visible list area  
When the user hovers over the list or actively scrolls it  
Then a scrollbar appears |
| TC_CONWORK_014 | @ui @edge @positive | Scrollbar hides when not hovering or scrolling | Given the widget list content overflows and a scrollbar is currently visible  
When the user stops hovering over the list and is not actively scrolling  
Then the scrollbar returns to hidden |
| TC_CONWORK_015 | @ui @edge @negative | No scrollbar appears when content does not overflow | Given the widget contains few enough cards that content fits within the visible list area  
When the user hovers over the list  
Then no scrollbar appears |
| TC_CONWORK_016 | @ui @positive @smoke | Clicking a card resumes the saved workflow with pre-filled data at the correct step | Given a document/workflow card is displayed with previously entered data saved server-side  
When the user clicks the card  
Then they are returned directly into the saved workflow  
And all previously entered data is pre-filled  
And the workflow resumes at the exact step where they left off |
| TC_CONWORK_017 | @ui @accessibility @positive @smoke | Pressing Enter on a focused card resumes the saved workflow | Given a document/workflow card is keyboard-focused  
When the user presses Enter  
Then they are returned directly into the saved workflow  
And all previously entered data is pre-filled  
And the workflow resumes at the exact step where they left off |
| TC_CONWORK_018 | @ui @accessibility @positive | Pressing Space on a focused card resumes the saved workflow | Given a document/workflow card is keyboard-focused  
When the user presses Space  
Then they are returned directly into the saved workflow  
And all previously entered data is pre-filled  
And the workflow resumes at the exact step where they left off |
| TC_CONWORK_019 | @ui @analytics @positive @smoke | Clicking thumbs-up launches the Pendo feedback flow | Given the Continue Work widget is visible  
When the user clicks the thumbs-up icon on a card  
Then the Pendo feedback flow launches |
| TC_CONWORK_020 | @ui @analytics @positive | Clicking thumbs-down launches the Pendo feedback flow | Given the Continue Work widget is visible  
When the user clicks the thumbs-down icon on a card  
Then the Pendo feedback flow launches |
| TC_CONWORK_021 | @ui @analytics @edge @negative | Clicking thumbs-up/down does not also trigger card navigation | Given the Continue Work widget is visible with at least one card  
When the user clicks the thumbs-up or thumbs-down icon on a card  
Then the Pendo feedback flow launches  
And the user is not navigated into the saved workflow |
| TC_CONWORK_022 | @ui @negative @edge | No filter, sort, or export controls are present on the widget | Given the Continue Work widget has rendered with in-progress items  
When the widget is viewed  
Then no filter controls are present  
And no sort controls are present  
And no export controls are present  
And item order is fixed by most-recently-updated |
| TC_CONWORK_023 | @ui @positive @edge | Document is removed from the widget once it reaches a completed/final state | Given a document previously appeared in the Continue Work widget with status Draft  
When the document reaches a completed/final state that is no longer Draft, Needs Signature, Payment Pending, or Awaiting ASIC  
And the widget renders  
Then that document no longer appears in the Continue Work widget |
| TC_CONWORK_024 | @ui @edge @positive | Widget scope remains limited to incomplete/in-progress work only | Given a user has both in-progress documents and fully completed documents  
When the widget renders  
Then only the in-progress documents in Draft, Needs Signature, Payment Pending, or Awaiting ASIC status are displayed  
And completed documents are excluded |
| TC_CONWORK_025 | @ui @negative @edge | Out-of-scope Release 1 workflow types do not appear in the widget | Given a user has in-progress work of types add multiple companies, add existing trust, add existing fund, new I&DV request, or make payment  
When the widget renders  
Then none of those in-progress workflow types are displayed  
And only saved documents are surfaced |
| TC_CONWORK_026 | @ui @positive @smoke | Widget surfaces only saved documents in Release 1 | Given Release 1 is active  
And a user has an in-progress saved document  
When the widget populates  
Then the saved document is displayed as a card |
| TC_CONWORK_027 | @accessibility @positive @smoke | Keyboard-only user can tab through all document cards | Given a keyboard-only user is navigating the widget  
And multiple document cards are displayed  
When they press Tab repeatedly  
Then each card is reachable in sequence via keyboard focus |
| TC_CONWORK_028 | @accessibility @positive | Enter/Space on a focused card opens the saved workflow for keyboard-only users | Given a keyboard-only user has tabbed to a document card and it is focused  
When they press Enter or Space  
Then the saved workflow opens |
| TC_CONWORK_029 | @accessibility @edge @positive | Focus order and visible focus indicator are correct across cards | Given multiple document cards are displayed in the widget  
When a keyboard-only user tabs through the cards  
Then a visible focus indicator is shown on the currently focused card  
And focus order follows the visual order of the cards |
| TC_CONWORK_030 | @negative @edge @ui | Locally cached data is not used to populate the widget | Given a user's in-progress document data exists both server-side and in a stale local cache on the user's device  
When the widget retrieves data to display  
Then the data shown is sourced from server-side storage  
And the locally cached copy is not used |
| TC_CONWORK_031 | @negative @edge | Widget does not render stale local data after server-side deletion | Given a document was previously cached locally on the user's device  
And the document has since been deleted or completed server-side  
When the widget renders  
Then the widget does not display the stale locally cached document |
| TC_CONWORK_032 | @mobile @ui @positive | Widget renders correctly on a mobile viewport | Given a user loads Workspace on a mobile viewport  
And they have an in-progress document  
When the Continue Work widget renders  
Then the card displays document type, entity/workflow name, a status badge, a description line, and "Last edited by [name], [date/time]" |
| TC_CONWORK_033 | @mobile @ui @positive | Tapping a card on mobile resumes the saved workflow | Given a user is viewing the Continue Work widget on a mobile viewport  
And a document/workflow card is displayed  
When the user taps the card  
Then they are returned directly into the saved workflow  
And all previously entered data is pre-filled |
| TC_CONWORK_034 | @mobile @ui @edge | Mobile empty state displays CTA and remains tappable | Given a user has zero in-progress documents or workflows  
And they are viewing Workspace on a mobile viewport  
When the Continue Work widget renders  
Then the empty state displays with heading "Continue Work", message "No work to continue yet", subtext, and a "Create a new document" CTA button  
And the CTA button is tappable |
| TC_CONWORK_035 | @mobile @ui @edge | Drag handle and feedback icons are accessible via touch on mobile | Given a user is viewing the Continue Work widget on a mobile viewport  
When the user taps or long-presses a document card  
Then the thumbs-up and thumbs-down icons become visible and remain tappable |
| TC_CONWORK_036 | @gap @negative @edge | Assigned user field is not displayed as it is unconfirmed for Release 1 | Given the "Assigned user" field is marked (TBC) in the UX specs and is not part of the confirmed Release 1 field set  
When a document/workflow card renders in the Continue Work widget  
Then no "Assigned user" field is displayed on the card  
And the card only shows document type, entity/workflow name, status badge, description line, and last edited by/date |
| TC_CONWORK_037 | @gap @edge | Coverage of PRD Favourited documents requirement is unclear and needs confirmation | Given the PRD includes a "Favourited documents" requirement  
And it is unclear whether the Continue Work widget fully satisfies that requirement  
When the widget's in-progress document set is reviewed against the PRD's Favourited documents requirement  
Then the coverage gap should be confirmed with the product owner before this AC can be considered fully verified |
| TC_CONWORK_038 | @gap @edge | Scope of practice-wide versus per-user work surfacing is unconfirmed | Given the Deliverable Breakdown does not confirm whether work surfacing is per-user only or also practice-wide  
When a user who belongs to a practice with in-progress work started by other users loads Workspace  
Then it is unclear whether those other users' in-progress items should appear in this user's Continue Work widget  
And this scope ambiguity should be confirmed with the product owner before this behaviour is considered verified |
| TC_CONWORK_039 | @negative @edge | Widget handles a document with a missing or null last-edited timestamp gracefully | Given an in-progress document exists with a missing or null last-edited timestamp  
When the Continue Work widget renders  
Then the widget does not error or crash  
And the card either falls back to a safe default display or is excluded from sort-order-dependent rendering without breaking the list |
| TC_CONWORK_040 | @negative @edge | Widget handles server error when retrieving in-progress documents | Given the server-side storage for in-progress documents is unavailable or returns an error  
When the Continue Work widget attempts to load  
Then the widget does not display stale or locally cached data  
And an appropriate error or fallback state is shown instead of a broken card list |

## JSON Export

```json
[
  {
    "scenario_id": "TC_CONWORK_001",
    "tags": "@ui @positive @smoke",
    "scenario": "Widget displays in-progress document card with all required fields",
    "description": "Given a user has a document with saved state in Draft status\nWhen they load Workspace\nThen the Continue Work widget displays it as a card\nAnd the card shows document type, entity/workflow name, a status badge, a description line, and \"Last edited by [name], [date/time]\""
  },
  {
    "scenario_id": "TC_CONWORK_002",
    "tags": "@ui @positive",
    "scenario": "Widget displays card for document in Needs Signature status",
    "description": "Given a user has a document with saved state in Needs Signature status\nWhen they load Workspace\nThen the Continue Work widget displays it as a card\nAnd the status badge reads Needs Signature"
  },
  {
    "scenario_id": "TC_CONWORK_003",
    "tags": "@ui @positive",
    "scenario": "Widget displays card for document in Payment Pending status",
    "description": "Given a user has a document with saved state in Payment Pending status\nWhen they load Workspace\nThen the Continue Work widget displays it as a card\nAnd the status badge reads Payment Pending"
  },
  {
    "scenario_id": "TC_CONWORK_004",
    "tags": "@ui @positive",
    "scenario": "Widget displays card for document in Awaiting ASIC status",
    "description": "Given a user has a document with saved state in Awaiting ASIC status\nWhen they load Workspace\nThen the Continue Work widget displays it as a card\nAnd the status badge reads Awaiting ASIC"
  },
  {
    "scenario_id": "TC_CONWORK_005",
    "tags": "@ui @positive @smoke",
    "scenario": "Cards are sorted most-recently-updated first",
    "description": "Given a user has multiple in-progress documents and workflows with different last-updated timestamps\nWhen they load Workspace\nThen the Continue Work widget displays the cards ordered from most-recently-updated to least-recently-updated"
  },
  {
    "scenario_id": "TC_CONWORK_006",
    "tags": "@ui @positive",
    "scenario": "Card ordering updates after editing an older item",
    "description": "Given a user has multiple in-progress documents displayed in the Continue Work widget\nWhen they resume and save further edits to a document that was not the most recently updated\nAnd they reload Workspace\nThen that document's card moves to the top of the list as the most-recently-updated item"
  },
  {
    "scenario_id": "TC_CONWORK_007",
    "tags": "@ui @positive @smoke",
    "scenario": "Empty state displays when there are zero in-progress items",
    "description": "Given a user has zero in-progress documents or workflows\nWhen the Continue Work widget renders\nThen an empty state displays with heading \"Continue Work\"\nAnd message \"No work to continue yet\"\nAnd subtext \"Drafts and in-progress documents will appear here once you've started working on them\"\nAnd a \"Create a new document\" CTA button is displayed"
  },
  {
    "scenario_id": "TC_CONWORK_008",
    "tags": "@ui @positive @smoke",
    "scenario": "Create a new document CTA navigates to documents/forms list",
    "description": "Given the empty state is displayed in the Continue Work widget\nWhen the user clicks \"Create a new document\"\nThen they are navigated to the original documents/forms list"
  },
  {
    "scenario_id": "TC_CONWORK_009",
    "tags": "@ui @accessibility @positive",
    "scenario": "Create a new document CTA is keyboard operable",
    "description": "Given the empty state is displayed in the Continue Work widget\nWhen the user tabs to focus the \"Create a new document\" button\nAnd presses Enter\nThen they are navigated to the original documents/forms list"
  },
  {
    "scenario_id": "TC_CONWORK_010",
    "tags": "@ui @positive",
    "scenario": "Drag handle and feedback icons appear on hover",
    "description": "Given the widget is in its default state\nWhen the user hovers over a document card\nThen the drag handle becomes visible\nAnd the thumbs-up and thumbs-down icons become visible"
  },
  {
    "scenario_id": "TC_CONWORK_011",
    "tags": "@ui @accessibility @positive",
    "scenario": "Drag handle and feedback icons appear on keyboard focus",
    "description": "Given the widget is in its default state\nWhen the user tabs to keyboard-focus a document card\nThen the drag handle becomes visible\nAnd the thumbs-up and thumbs-down icons become visible"
  },
  {
    "scenario_id": "TC_CONWORK_012",
    "tags": "@ui @edge @positive",
    "scenario": "Drag handle and feedback icons hide when hover/focus ends",
    "description": "Given the drag handle and feedback icons are visible on a hovered card\nWhen the user moves the pointer away from the card and no card is keyboard-focused\nThen the drag handle and thumbs-up/thumbs-down icons return to hidden"
  },
  {
    "scenario_id": "TC_CONWORK_013",
    "tags": "@ui @edge @positive",
    "scenario": "Scrollbar appears on hover when card content overflows",
    "description": "Given the widget contains enough cards that content overflows the visible list area\nWhen the user hovers over the list or actively scrolls it\nThen a scrollbar appears"
  },
  {
    "scenario_id": "TC_CONWORK_014",
    "tags": "@ui @edge @positive",
    "scenario": "Scrollbar hides when not hovering or scrolling",
    "description": "Given the widget list content overflows and a scrollbar is currently visible\nWhen the user stops hovering over the list and is not actively scrolling\nThen the scrollbar returns to hidden"
  },
  {
    "scenario_id": "TC_CONWORK_015",
    "tags": "@ui @edge @negative",
    "scenario": "No scrollbar appears when content does not overflow",
    "description": "Given the widget contains few enough cards that content fits within the visible list area\nWhen the user hovers over the list\nThen no scrollbar appears"
  },
  {
    "scenario_id": "TC_CONWORK_016",
    "tags": "@ui @positive @smoke",
    "scenario": "Clicking a card resumes the saved workflow with pre-filled data at the correct step",
    "description": "Given a document/workflow card is displayed with previously entered data saved server-side\nWhen the user clicks the card\nThen they are returned directly into the saved workflow\nAnd all previously entered data is pre-filled\nAnd the workflow resumes at the exact step where they left off"
  },
  {
    "scenario_id": "TC_CONWORK_017",
    "tags": "@ui @accessibility @positive @smoke",
    "scenario": "Pressing Enter on a focused card resumes the saved workflow",
    "description": "Given a document/workflow card is keyboard-focused\nWhen the user presses Enter\nThen they are returned directly into the saved workflow\nAnd all previously entered data is pre-filled\nAnd the workflow resumes at the exact step where they left off"
  },
  {
    "scenario_id": "TC_CONWORK_018",
    "tags": "@ui @accessibility @positive",
    "scenario": "Pressing Space on a focused card resumes the saved workflow",
    "description": "Given a document/workflow card is keyboard-focused\nWhen the user presses Space\nThen they are returned directly into the saved workflow\nAnd all previously entered data is pre-filled\nAnd the workflow resumes at the exact step where they left off"
  },
  {
    "scenario_id": "TC_CONWORK_019",
    "tags": "@ui @analytics @positive @smoke",
    "scenario": "Clicking thumbs-up launches the Pendo feedback flow",
    "description": "Given the Continue Work widget is visible\nWhen the user clicks the thumbs-up icon on a card\nThen the Pendo feedback flow launches"
  },
  {
    "scenario_id": "TC_CONWORK_020",
    "tags": "@ui @analytics @positive",
    "scenario": "Clicking thumbs-down launches the Pendo feedback flow",
    "description": "Given the Continue Work widget is visible\nWhen the user clicks the thumbs-down icon on a card\nThen the Pendo feedback flow launches"
  },
  {
    "scenario_id": "TC_CONWORK_021",
    "tags": "@ui @analytics @edge @negative",
    "scenario": "Clicking thumbs-up/down does not also trigger card navigation",
    "description": "Given the Continue Work widget is visible with at least one card\nWhen the user clicks the thumbs-up or thumbs-down icon on a card\nThen the Pendo feedback flow launches\nAnd the user is not navigated into the saved workflow"
  },
  {
    "scenario_id": "TC_CONWORK_022",
    "tags": "@ui @negative @edge",
    "scenario": "No filter, sort, or export controls are present on the widget",
    "description": "Given the Continue Work widget has rendered with in-progress items\nWhen the widget is viewed\nThen no filter controls are present\nAnd no sort controls are present\nAnd no export controls are present\nAnd item order is fixed by most-recently-updated"
  },
  {
    "scenario_id": "TC_CONWORK_023",
    "tags": "@ui @positive @edge",
    "scenario": "Document is removed from the widget once it reaches a completed/final state",
    "description": "Given a document previously appeared in the Continue Work widget with status Draft\nWhen the document reaches a completed/final state that is no longer Draft, Needs Signature, Payment Pending, or Awaiting ASIC\nAnd the widget renders\nThen that document no longer appears in the Continue Work widget"
  },
  {
    "scenario_id": "TC_CONWORK_024",
    "tags": "@ui @edge @positive",
    "scenario": "Widget scope remains limited to incomplete/in-progress work only",
    "description": "Given a user has both in-progress documents and fully completed documents\nWhen the widget renders\nThen only the in-progress documents in Draft, Needs Signature, Payment Pending, or Awaiting ASIC status are displayed\nAnd completed documents are excluded"
  },
  {
    "scenario_id": "TC_CONWORK_025",
    "tags": "@ui @negative @edge",
    "scenario": "Out-of-scope Release 1 workflow types do not appear in the widget",
    "description": "Given a user has in-progress work of types add multiple companies, add existing trust, add existing fund, new I&DV request, or make payment\nWhen the widget renders\nThen none of those in-progress workflow types are displayed\nAnd only saved documents are surfaced"
  },
  {
    "scenario_id": "TC_CONWORK_026",
    "tags": "@ui @positive @smoke",
    "scenario": "Widget surfaces only saved documents in Release 1",
    "description": "Given Release 1 is active\nAnd a user has an in-progress saved document\nWhen the widget populates\nThen the saved document is displayed as a card"
  },
  {
    "scenario_id": "TC_CONWORK_027",
    "tags": "@accessibility @positive @smoke",
    "scenario": "Keyboard-only user can tab through all document cards",
    "description": "Given a keyboard-only user is navigating the widget\nAnd multiple document cards are displayed\nWhen they press Tab repeatedly\nThen each card is reachable in sequence via keyboard focus"
  },
  {
    "scenario_id": "TC_CONWORK_028",
    "tags": "@accessibility @positive",
    "scenario": "Enter/Space on a focused card opens the saved workflow for keyboard-only users",
    "description": "Given a keyboard-only user has tabbed to a document card and it is focused\nWhen they press Enter or Space\nThen the saved workflow opens"
  },
  {
    "scenario_id": "TC_CONWORK_029",
    "tags": "@accessibility @edge @positive",
    "scenario": "Focus order and visible focus indicator are correct across cards",
    "description": "Given multiple document cards are displayed in the widget\nWhen a keyboard-only user tabs through the cards\nThen a visible focus indicator is shown on the currently focused card\nAnd focus order follows the visual order of the cards"
  },
  {
    "scenario_id": "TC_CONWORK_030",
    "tags": "@negative @edge @ui",
    "scenario": "Locally cached data is not used to populate the widget",
    "description": "Given a user's in-progress document data exists both server-side and in a stale local cache on the user's device\nWhen the widget retrieves data to display\nThen the data shown is sourced from server-side storage\nAnd the locally cached copy is not used"
  },
  {
    "scenario_id": "TC_CONWORK_031",
    "tags": "@negative @edge",
    "scenario": "Widget does not render stale local data after server-side deletion",
    "description": "Given a document was previously cached locally on the user's device\nAnd the document has since been deleted or completed server-side\nWhen the widget renders\nThen the widget does not display the stale locally cached document"
  },
  {
    "scenario_id": "TC_CONWORK_032",
    "tags": "@mobile @ui @positive",
    "scenario": "Widget renders correctly on a mobile viewport",
    "description": "Given a user loads Workspace on a mobile viewport\nAnd they have an in-progress document\nWhen the Continue Work widget renders\nThen the card displays document type, entity/workflow name, a status badge, a description line, and \"Last edited by [name], [date/time]\""
  },
  {
    "scenario_id": "TC_CONWORK_033",
    "tags": "@mobile @ui @positive",
    "scenario": "Tapping a card on mobile resumes the saved workflow",
    "description": "Given a user is viewing the Continue Work widget on a mobile viewport\nAnd a document/workflow card is displayed\nWhen the user taps the card\nThen they are returned directly into the saved workflow\nAnd all previously entered data is pre-filled"
  },
  {
    "scenario_id": "TC_CONWORK_034",
    "tags": "@mobile @ui @edge",
    "scenario": "Mobile empty state displays CTA and remains tappable",
    "description": "Given a user has zero in-progress documents or workflows\nAnd they are viewing Workspace on a mobile viewport\nWhen the Continue Work widget renders\nThen the empty state displays with heading \"Continue Work\", message \"No work to continue yet\", subtext, and a \"Create a new document\" CTA button\nAnd the CTA button is tappable"
  },
  {
    "scenario_id": "TC_CONWORK_035",
    "tags": "@mobile @ui @edge",
    "scenario": "Drag handle and feedback icons are accessible via touch on mobile",
    "description": "Given a user is viewing the Continue Work widget on a mobile viewport\nWhen the user taps or long-presses a document card\nThen the thumbs-up and thumbs-down icons become visible and remain tappable"
  },
  {
    "scenario_id": "TC_CONWORK_036",
    "tags": "@gap @negative @edge",
    "scenario": "Assigned user field is not displayed as it is unconfirmed for Release 1",
    "description": "Given the \"Assigned user\" field is marked (TBC) in the UX specs and is not part of the confirmed Release 1 field set\nWhen a document/workflow card renders in the Continue Work widget\nThen no \"Assigned user\" field is displayed on the card\nAnd the card only shows document type, entity/workflow name, status badge, description line, and last edited by/date"
  },
  {
    "scenario_id": "TC_CONWORK_037",
    "tags": "@gap @edge",
    "scenario": "Coverage of PRD Favourited documents requirement is unclear and needs confirmation",
    "description": "Given the PRD includes a \"Favourited documents\" requirement\nAnd it is unclear whether the Continue Work widget fully satisfies that requirement\nWhen the widget's in-progress document set is reviewed against the PRD's Favourited documents requirement\nThen the coverage gap should be confirmed with the product owner before this AC can be considered fully verified"
  },
  {
    "scenario_id": "TC_CONWORK_038",
    "tags": "@gap @edge",
    "scenario": "Scope of practice-wide versus per-user work surfacing is unconfirmed",
    "description": "Given the Deliverable Breakdown does not confirm whether work surfacing is per-user only or also practice-wide\nWhen a user who belongs to a practice with in-progress work started by other users loads Workspace\nThen it is unclear whether those other users' in-progress items should appear in this user's Continue Work widget\nAnd this scope ambiguity should be confirmed with the product owner before this behaviour is considered verified"
  },
  {
    "scenario_id": "TC_CONWORK_039",
    "tags": "@negative @edge",
    "scenario": "Widget handles a document with a missing or null last-edited timestamp gracefully",
    "description": "Given an in-progress document exists with a missing or null last-edited timestamp\nWhen the Continue Work widget renders\nThen the widget does not error or crash\nAnd the card either falls back to a safe default display or is excluded from sort-order-dependent rendering without breaking the list"
  },
  {
    "scenario_id": "TC_CONWORK_040",
    "tags": "@negative @edge",
    "scenario": "Widget handles server error when retrieving in-progress documents",
    "description": "Given the server-side storage for in-progress documents is unavailable or returns an error\nWhen the Continue Work widget attempts to load\nThen the widget does not display stale or locally cached data\nAnd an appropriate error or fallback state is shown instead of a broken card list"
  }
]
```