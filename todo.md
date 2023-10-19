This is a todo-list for Quotealine
Quotes:
- Allow for the creation of quotes
    - Store quotes in firebase (Accomplished)
    - Quote Creation Screen
    - Timestamp for quote, when said and when createdb

User:


Authentication:
- Google, Apple Auth

Architecture:
- Create route generator 
- Create parent Firebase interaction class

Current Roadmap:
1. Implement the ability to create and join Folders *** (FOLDER)
2. Allow the ability to create quotes associated with folders *** (FOLDER, QUOTES) x
    2.1. Quote fields: Folder (can only add to folder with which you are a member), quote content, speaker (maybe)
3. Prettify the UI (PRETTIFICATION)
    3.1. QUOTES: with source set at bottom
    3.2 LOGIN: Clean bubbled buttons with Enter key working to send the user in
    3.3 FOLDER: Cleanly organized, ultimately allowing the user to set an icon for the folder
    3.4 ACCOUNT PAGE: Clean buttons allowing the user to modify their account in <3 clicks
4. Deploy to web, Google play (if easy) (PRODUCTION)
    4.1. Associate web dev with github repo
5. Associate Quotes created with the user that created them (QUOTES)
    5.1. Allow only the user who created them to edit the quote
6. Allow app sorting by speaker, time, or keywords (QUOTES, SORTING)
6. Add Google, Apple Auth (AUTHENTICATION)
7. Create Pagination (QUOTES, SORTING)
8. Create Account tabs, allowing users to easily delete/modify their account *** (USER)
9. Deploy onto App Store (PRODUCTION)
10. Release as open source (PRODUCTION)
11. Allow users to tag other members in the quote, sending an alert (QUOTES, USER)
12. Introduce Mod privileges, allowing creators of a Folder to delete posts or ban members (FOLDER, QUTOES, USER)

Currently in Progress:
- Creating Folder Class x
- Implementing Folder class in Firebase x
- Creating folder screen x
- Testing creation and display of folders x
- Sync Quotes with Folders x
- Sync Users with Folders x
- add Timestamps (creation) to Folder, User, and Quote x
- Security (obscurate UserInfo and FolderInfo)
- Allow Users to Join Folders x
- Allow Users to add other users to the folder
- Allow Users to add Friends x
- Make Folder page a stream
- Enable more fields for quote creation
- Prettify folders
- Prettify quotes
- Prettify login screen
- Prettify Profile Screen
- Deploy