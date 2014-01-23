BrowseOverflow
==============

Example project from the book "iOS Test-Driven Development"

Issues
-----------------

1. StackOverflowCommunicator does not support more than one request at a time. It cancels the previous NSURLConnection before creating a new one. Even if you fix that issue, you also need to address how event handler blocks would overwrite each other.
2. Questions and Answers are added multiple times by re-navigating. Need to enforce uniqueness at the model level.
3. Multiline UILabel issues in the question body and answer text UI -- need to find way to make text grow vertically.
4. Strange issue with auto layout and cell text field "growing" during scroll. May be related to how it handles multiline text.