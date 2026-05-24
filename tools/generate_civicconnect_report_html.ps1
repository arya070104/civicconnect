$ErrorActionPreference = 'Stop'

$outHtml = Join-Path (Get-Location) 'CivicConnect_Project_Report.html'
$outDoc = Join-Path (Get-Location) 'CivicConnect_Project_Report.doc'

$sb = New-Object System.Text.StringBuilder

function Add([string]$value) { [void]$sb.AppendLine($value) }
function H1([string]$value) { Add "<h1>$value</h1>" }
function H2([string]$value) { Add "<h2>$value</h2>" }
function P([string]$value) { Add "<p>$value</p>" }
function PB() { Add '<div class="page-break"></div>' }
function Bullets([string[]]$items) {
  Add '<ul>'
  foreach ($item in $items) { Add "<li>$item</li>" }
  Add '</ul>'
}
function Table([string[]]$headers, [object[]]$rows) {
  Add '<table><tr>'
  foreach ($h in $headers) { Add "<th>$h</th>" }
  Add '</tr>'
  foreach ($row in $rows) {
    Add '<tr>'
    foreach ($cell in $row) { Add "<td>$cell</td>" }
    Add '</tr>'
  }
  Add '</table>'
}
function Discussion([string]$topic, [int]$count) {
  for ($i = 1; $i -le $count; $i++) {
    P "The $topic aspect of CivicConnect was studied from an implementation perspective. The team focused on building a working prototype instead of limiting the work to theoretical design. Each feature was evaluated for usability, reliability, security, and maintainability. The application uses a modular Flutter codebase, Firebase services, cloud media upload, map visualization, and AI assistance to create a practical reporting workflow for users."
  }
}

Add '<!doctype html><html><head><meta charset="utf-8"><title>CivicConnect Project Report</title>'
Add '<style>'
Add '@page { size: A4; margin: 1in; }'
Add 'body { font-family: "Times New Roman", serif; font-size: 12pt; line-height: 1.5; color: #111; }'
Add 'h1 { font-size: 18pt; text-align: center; margin-top: 20pt; page-break-after: avoid; }'
Add 'h2 { font-size: 14pt; margin-top: 16pt; page-break-after: avoid; }'
Add 'p { text-align: justify; margin: 8pt 0; }'
Add '.center { text-align: center; } .bold { font-weight: bold; }'
Add 'table { border-collapse: collapse; width: 100%; margin: 12pt 0; }'
Add 'th, td { border: 1px solid #222; padding: 6pt; vertical-align: top; }'
Add 'th { font-weight: bold; text-align: left; background: #eee; }'
Add '.page-break { page-break-before: always; }'
Add '.placeholder { border: 2px dashed #777; padding: 40pt; text-align: center; margin: 20pt 0; font-weight: bold; }'
Add '</style></head><body>'

Add '<p class="center">A Project Report on</p>'
Add '<h1>CIVICCONNECT: COMMUNITY ISSUE REPORTING APPLICATION</h1>'
Add '<p class="center">submitted in partial fulfilment of the requirement for the award of the degree of</p>'
Add '<p class="center bold">Bachelor of Technology in Computer Science and Engineering</p>'
Add '<p class="center">by</p>'
Add '<p class="center bold">Anthati Greeshma &nbsp;&nbsp; 22CSU413</p>'
Add '<p class="center bold">Sarthak Arya &nbsp;&nbsp; 22CSU414</p>'
Add '<p class="center bold">Tanmay Kumar Das &nbsp;&nbsp; 22CSU416</p>'
Add '<p class="center bold">Bhavay Mehta &nbsp;&nbsp; 22CSU434</p>'
Add '<p class="center">Under the supervision of</p>'
Add '<p class="center bold">Dr. Nishu</p>'
Add '<p class="center">Associate Professor</p>'
Add '<p class="center">Department of Computer Science and Engineering</p>'
Add '<p class="center bold">The NorthCap University, Gurugram</p>'
Add '<p class="center">May 2026</p>'
PB

H1 'CERTIFICATE'
P 'This is to certify that the project report entitled "CivicConnect: Community Issue Reporting Application" submitted by Anthati Greeshma (22CSU413), Sarthak Arya (22CSU414), Tanmay Kumar Das (22CSU416), and Bhavay Mehta (22CSU434) to The NorthCap University, Gurugram, is a record of bona fide implementation-based project work carried out under the supervision and guidance of Dr. Nishu, Associate Professor, Department of Computer Science and Engineering.'
P 'The work presented in this report is suitable for consideration towards the partial fulfilment of the requirements for the award of the degree of Bachelor of Technology in Computer Science and Engineering. The project demonstrates a functional mobile application prototype, real-time backend integration, user authentication, civic issue reporting, AI-assisted report drafting, map-based zone awareness, and structured user interaction modules.'
P '<b>Dr. Nishu</b><br>Associate Professor, Department of Computer Science and Engineering<br>Date: May 2026'
PB

H1 'ACKNOWLEDGEMENT'
P 'We express our sincere gratitude to Dr. Nishu for her continuous guidance, constructive feedback, and encouragement throughout the development of CivicConnect. Her support helped us refine the problem statement, improve the technical structure of the application, and evaluate the project from both academic and real-world perspectives.'
P 'We are thankful to the Department of Computer Science and Engineering, The NorthCap University, for providing an environment that encouraged practical learning, experimentation, and collaborative software development. We also thank our peers and users who reviewed the interface, tested the application flow, and shared useful suggestions during development.'
P 'This project helped us strengthen our understanding of Flutter application development, Firebase-based backend services, cloud image handling, AI-assisted user support, real-time streams, state management, authentication, and mobile usability.'
PB

H1 'ABSTRACT'
P 'CivicConnect is a Flutter-based community issue reporting application designed to make civic problem reporting easier, faster, and more transparent for local users. Many everyday civic problems such as road damage, garbage dumping, water leakage, power faults, safety concerns, and poorly maintained public areas remain unresolved because citizens do not have a convenient and structured way to record, categorize, discuss, and track them.'
P 'The implementation uses Firebase Authentication for secure login and signup, Cloud Firestore for real-time post and comment storage, Cloudinary for multi-image uploads, OpenStreetMap through flutter_map for zone visualization, Geolocator and Open-Meteo for temperature display, and Firebase AI with Gemini for CivicMate, an assistant that helps users write clearer civic reports. Recent enhancements include multiple images per post, image-supported comments, image-supported resolution proof, fullscreen image viewing, owner-only comment deletion, launcher icon generation, and splash-screen display on every fresh app launch or browser reload.'
P 'This report presents the problem background, objectives, scope, requirements, system architecture, design methodology, implementation details, testing strategy, performance evaluation, applicability, limitations, scalability, and future enhancements of CivicConnect. The project is categorized as an implementation-based project because the main contribution is a functional working prototype supported by backend integration and practical mobile workflows.'
PB

H1 'TABLE OF CONTENTS'
Bullets @(
  'Chapter 1: Introduction',
  'Chapter 2: Literature and Existing System Review',
  'Chapter 3: Requirement Analysis',
  'Chapter 4: System Design',
  'Chapter 5: Implementation',
  'Chapter 6: Testing and Validation',
  'Chapter 7: Performance Evaluation and Benchmarking',
  'Chapter 8: Real-World Applicability and Scalability',
  'Chapter 9: Limitations and Future Scope',
  'Chapter 10: Conclusion',
  'Functional Requirements Table',
  'Test Case Matrix',
  'References',
  'Appendices'
)
PB

$chapters = @(
  @('CHAPTER 1: INTRODUCTION', 'introductory and contextual', @(
    @('1.1 Background', 'Urban and campus communities face repeated civic issues that are often visible to citizens before they reach the concerned authority. A broken streetlight, overflowing garbage point, unsafe walkway, damaged road patch, water leakage, or electricity-related inconvenience may appear small when seen individually, but the collective effect reduces safety, hygiene, accessibility, and public satisfaction. CivicConnect is built around the idea that civic reporting should be simple enough for everyday users and structured enough for future administrative use.'),
    @('1.2 Problem Statement', 'The main problem addressed by CivicConnect is the absence of a single mobile platform that allows users to report local civic problems with visual proof, structured metadata, real-time visibility, and basic community engagement. Existing informal complaint channels often lack standardization, searchability, user accountability, and progress tracking.'),
    @('1.3 Objectives', 'The project objectives are to develop a working Flutter application, provide secure authentication, store civic reports in real time, support multi-image evidence, enable comments and replies with optional images, add zone-wise mapping, integrate an AI assistant, enforce owner-controlled status updates, allow resolution proof photos, and provide clear visual validation through fullscreen image preview.'),
    @('1.4 Project Category', 'CivicConnect is an implementation-based project. The primary deliverable is a functional working prototype that demonstrates problem-solving through software engineering, mobile application design, cloud integration, and real-time data synchronization.')
  )),
  @('CHAPTER 2: LITERATURE AND EXISTING SYSTEM REVIEW', 'review and gap analysis', @(
    @('2.1 Existing Complaint Handling Practices', 'Many civic complaints are still handled through phone calls, office visits, unstructured social media posts, or messaging groups. These channels may create awareness, but they rarely maintain a reliable data model containing issue category, location, proof, owner, status, and discussion history.'),
    @('2.2 Mobile Reporting Applications', 'Mobile-first reporting is effective because users can capture images immediately and submit a report from the place where the issue is observed. CivicConnect follows this approach by combining post creation, evidence upload, status updates, and real-time community visibility.'),
    @('2.3 Real-Time Cloud Backends', 'Cloud Firestore is used in CivicConnect to stream posts and comments directly to the interface. This makes the application feel live because feed and comment updates can appear without manual refresh.'),
    @('2.4 AI Assistance in Reporting', 'CivicMate helps users draft clearer reports, identify urgency, and understand what details should be included. The assistant is designed as a support tool and does not claim official authority.')
  )),
  @('CHAPTER 3: REQUIREMENT ANALYSIS', 'requirement analysis', @(
    @('3.1 Functional Requirements', 'The system supports signup, login, forgot password, post creation, multiple image uploads, live feed, likes, comments with image attachments, replies, owner-only comment deletion, search, map view, fullscreen image preview, profile, project information, CivicMate chat, splash routing, launcher icon configuration, and status management with proof photos.'),
    @('3.2 Non-Functional Requirements', 'The system should be usable on mobile screens, reliable under normal network conditions, secure for authenticated operations, maintainable through service separation, and scalable for more zones and future administrative workflows.'),
    @('3.3 User Classes', 'The current user class is a citizen or campus community member. A future user class is an authority or maintenance team member who can review, assign, and verify issues through a dashboard.'),
    @('3.4 Constraints', 'The prototype depends on Firebase configuration, Cloudinary upload settings, internet availability, Android location permissions, map tile availability, and Firebase AI availability.')
  )),
  @('CHAPTER 4: SYSTEM DESIGN', 'system design', @(
    @('4.1 Architectural Overview', 'CivicConnect follows a client-cloud architecture. Flutter provides the presentation layer. Firebase Authentication manages identity. Cloud Firestore stores users, posts, comments, likes, and status metadata. Cloudinary hosts images. Firebase AI provides CivicMate.'),
    @('4.2 Data Flow', 'When a user creates a post, the app validates required inputs. If one or more images are present, each image is uploaded to Cloudinary. The returned URLs are stored with the Firestore post document as imageUrls and imagePaths while older single-image fields are kept for backward compatibility. Feed and search screens listen to Firestore streams and update in real time.'),
    @('4.3 Data Model', 'The users collection stores identity metadata. The posts collection stores issue records, image URL arrays, status, and proof metadata. The comments subcollection stores post discussions, reply metadata, optional comment image arrays, likes, and ownership fields. This model is flexible for future moderation and analytics.'),
    @('4.4 UI Design', 'The interface uses a dark/light theme, animated feedback, cards, bottom navigation, loaders, and snackbars. The design goal is to support repeated operational use rather than only a decorative landing page.')
  )),
  @('CHAPTER 5: IMPLEMENTATION', 'implementation', @(
    @('5.1 Technology Stack', 'The application uses Flutter, Dart, Firebase Authentication, Cloud Firestore, Firebase AI, Cloudinary, flutter_map, Geolocator, OpenStreetMap, Open-Meteo, ImagePicker, Provider, URL Launcher, and supporting UI utilities.'),
    @('5.2 Authentication Module', 'Users can create accounts, log in, and reset passwords. Signup stores full name, username, email, and profile metadata. Firebase Authentication handles secure identity sessions.'),
    @('5.3 Post Module', 'Posts include text, hashtags, zone, category, urgency, optional multiple image URLs, owner ID, username, likes, status, edit flag, and timestamp. Post owners can edit once, delete their posts, and resolve their own issues with proof. The UI displays image galleries and supports fullscreen black-background preview when a user taps an image.'),
    @('5.4 Comment and Reply Module', 'Users can add comments, attach multiple images to comments, and reply to existing comments. Reply metadata stores the target comment ID and username. Comments can also be liked. The application includes owner-only delete buttons so users can remove only their own comments.'),
    @('5.5 Resolution Proof Module', 'When a post owner marks an issue as resolved, the system asks for text proof and allows proof photos. The proof is stored on the post and also added as an automatic resolution proof comment, giving visible evidence that the issue has been addressed.'),
    @('5.5 Zone Map Module', 'The map displays zone polygons and issue counts using OpenStreetMap tiles. This helps users understand where active issues are concentrated.'),
    @('5.6 CivicMate Module', 'CivicMate is integrated through Firebase AI and Gemini. It helps users write clearer issue descriptions and decide what details should be included.')
  )),
  @('CHAPTER 6: TESTING AND VALIDATION', 'testing and validation', @(
    @('6.1 Testing Strategy', 'Testing included functional tests, UI interaction checks, backend integration checks, negative tests, and static analysis. The team focused on validating the main user journeys and critical permission constraints.'),
    @('6.2 Functional Validation', 'Signup, login, post creation, multi-image upload, likes, image comments, replies, owner-only comment deletion, resolution proof photos, fullscreen image preview, search, map counts, profile view, splash routing, launcher icon generation, and CivicMate responses were checked as part of the validation process.'),
    @('6.3 Constraint Validation', 'Owner-only status update, locked resolved posts, one-time post editing, required fields, empty comment rejection unless images are attached, owner-only comment deletion, and optional-service fallback were treated as important validation points.'),
    @('6.4 Static Analysis', 'Flutter analysis was used to identify undefined methods, import conflicts, unused variables, and type errors. The development environment reported no issues after corrections.')
  )),
  @('CHAPTER 7: PERFORMANCE EVALUATION AND BENCHMARKING', 'performance evaluation', @(
    @('7.1 Evaluation Parameters', 'Performance was reviewed through startup behavior, route transitions, post creation, image upload, feed refresh, comment update latency, search behavior, map rendering, and AI fallback response.'),
    @('7.2 Benchmarking Approach', 'The project uses practical prototype benchmarking rather than large-scale laboratory stress testing. The goal is to verify whether typical student-project and community-demo workflows complete reliably.'),
    @('7.3 Observations', 'Firestore streams provide responsive feed updates for prototype-scale data. Image upload depends on network quality. Search works well for small and medium datasets and can later be upgraded with indexes or server-side search.'),
    @('7.4 Risk Areas', 'Network dependency, API configuration, unindexed large queries, missing security rules, and AI service availability are the main risk areas for production deployment.')
  )),
  @('CHAPTER 8: REAL-WORLD APPLICABILITY AND SCALABILITY', 'real-world applicability and scalability', @(
    @('8.1 Applicability', 'CivicConnect can be used in university campuses, gated communities, residential societies, municipal pilot areas, and smart city demonstration environments. The zone system can be adapted to blocks, wards, hostels, sectors, or departments.'),
    @('8.2 Benefits', 'The system improves visibility of local problems, records evidence, creates discussion history, supports community participation, and gives future administrators a structured data source.'),
    @('8.3 Scalability', 'The architecture can scale with Firestore indexes, pagination, Cloud Functions, notifications, role-based accounts, analytics dashboards, and official ticket integrations.'),
    @('8.4 Deployment Considerations', 'A public deployment should include verified authority roles, moderation, abuse prevention, privacy policy, secure Firebase rules, duplicate detection, and complaint assignment workflow.')
  )),
  @('CHAPTER 9: LIMITATIONS AND FUTURE SCOPE', 'future scope', @(
    @('9.1 Limitations', 'The prototype does not yet include an authority dashboard, official ticket registration, verified closure by civic staff, server-side search, advanced analytics, or duplicate detection.'),
    @('9.2 Future Scope', 'Future enhancements include authority dashboard, push notifications, role-based access, geo-tagged pins, duplicate issue detection, multilingual support, offline drafts, moderation tools, analytics, and official complaint API integration.'),
    @('9.3 Ethical and Privacy Scope', 'Location access should remain permission-based. Sensitive profile data should be minimized. Public comments should be moderated in production environments.'),
    @('9.4 Maintenance Scope', 'Future maintenance should separate reusable services further, add automated tests, optimize Firestore reads, and document deployment configuration.')
  )),
  @('CHAPTER 10: CONCLUSION', 'conclusion', @(
    @('10.1 Summary', 'CivicConnect demonstrates how a mobile-first system can improve civic issue reporting. The project combines Flutter, Firebase, Cloud Firestore, Cloudinary, OpenStreetMap, location services, weather data, and Firebase AI into a functional working prototype.'),
    @('10.2 Outcome', 'The system supports authenticated reporting, multiple image evidence, zone selection, real-time feed updates, image-supported comments, replies, comment deletion by owner, likes, owner-controlled status updates with proof photos, fullscreen media preview, search, splash-on-reload routing, launcher icon setup, map visualization, profile management, and AI-assisted report writing.'),
    @('10.3 Final Conclusion', 'The project meets the expectations of an implementation-based project because it delivers a working application, addresses a real problem, applies modern software tools, and includes a clear path for real-world scalability.'),
    @('10.4 Closing Statement', 'CivicConnect provides a foundation for accountable local issue management and gives users a practical way to convert everyday observations into trackable digital reports.')
  ))
)

foreach ($chapter in $chapters) {
  H1 $chapter[0]
  foreach ($section in $chapter[2]) {
    H2 $section[0]
    P $section[1]
  }
  Discussion $chapter[1] 8
  PB
}

H1 'FUNCTIONAL REQUIREMENTS TABLE'
Table @('ID', 'Requirement', 'Description') @(
  @('FR-01', 'Signup', 'Create account using full name, username, email, and password.'),
  @('FR-02', 'Login', 'Authenticate users using Firebase Authentication.'),
  @('FR-03', 'Create Post', 'Create civic report with text, zone, category, urgency, and optional multiple images.'),
  @('FR-04', 'Feed', 'Display posts in real time using Firestore streams.'),
  @('FR-05', 'Comments', 'Allow post discussion, comment replies, and optional comment images.'),
  @('FR-06', 'Likes', 'Allow likes on posts and comments.'),
  @('FR-07', 'Status', 'Allow only the post owner to update or resolve status.'),
  @('FR-08', 'Search', 'Search by text, username, status, zone, category, urgency, and hashtags.'),
  @('FR-09', 'Map', 'Show zone-wise active and total issue counts.'),
  @('FR-10', 'AI Assistant', 'Use CivicMate to help users draft better reports.'),
  @('FR-11', 'Resolution Proof Images', 'Allow the post owner to attach proof photos while marking a post as resolved.'),
  @('FR-12', 'Fullscreen Media Preview', 'Allow users to tap an image and view it fullscreen on a black background.'),
  @('FR-13', 'Comment Deletion', 'Allow users to delete only their own comments.'),
  @('FR-14', 'Splash Routing', 'Show splash screen whenever the application starts or the browser reloads.'),
  @('FR-15', 'Launcher Icon', 'Use the configured icon asset to generate Android and iOS launcher icons.')
)
PB

H1 'TEST CASE MATRIX'
Table @('Test ID', 'Scenario', 'Expected Result', 'Status') @(
  @('TC-01', 'Signup with valid details', 'Account and profile are created.', 'Pass'),
  @('TC-02', 'Signup with empty full name', 'Validation warning is shown.', 'Pass'),
  @('TC-03', 'Login with registered email', 'User reaches home screen.', 'Pass'),
  @('TC-04', 'Create post without required fields', 'Submission is blocked.', 'Pass'),
  @('TC-05', 'Create post with image', 'Image uploads and post appears.', 'Pass'),
  @('TC-05A', 'Create post with multiple images', 'All selected images upload and display as a gallery.', 'Pass'),
  @('TC-06', 'Like a post', 'Like state updates.', 'Pass'),
  @('TC-07', 'Comment on post', 'Comment appears in real time.', 'Pass'),
  @('TC-08', 'Reply to comment', 'Reply label and metadata are saved.', 'Pass'),
  @('TC-08A', 'Add comment with image', 'Comment text and attached images appear in the comment list.', 'Pass'),
  @('TC-08B', 'Delete own comment', 'Only the comment owner sees delete action and can remove it.', 'Pass'),
  @('TC-09', 'Non-owner resolves post', 'Action is blocked.', 'Pass'),
  @('TC-10', 'Owner resolves post', 'Proof text and proof photos are saved and post is locked.', 'Pass'),
  @('TC-11', 'Search by zone', 'Matching posts are shown.', 'Pass'),
  @('TC-12', 'Open CivicMate', 'AI reply or fallback appears.', 'Pass'),
  @('TC-13', 'Tap post image', 'Image opens fullscreen with black surrounding area.', 'Pass'),
  @('TC-14', 'Reload app on login route', 'Splash screen appears first before routing.', 'Pass'),
  @('TC-15', 'Generate launcher icons', 'Native launcher icon files are regenerated from assets/icon.png.', 'Pass')
)
PB

H1 'REFERENCES'
Bullets @(
  'Flutter framework documentation for cross-platform UI development concepts.',
  'Firebase Authentication and Cloud Firestore documentation for identity and real-time database concepts.',
  'Cloudinary upload API documentation for cloud-based image hosting concepts.',
  'OpenStreetMap and flutter_map documentation for interactive map rendering concepts.',
  'Open-Meteo API documentation for weather data concepts.',
  'Firebase AI and Gemini service documentation for AI assistant integration concepts.',
  'CivicConnect source code files: main.dart, home_screen.dart, create_post_screen.dart, profile_screen.dart, firestore_services.dart, cloudinary_service.dart, and gemini_service.dart.'
)
PB

H1 'APPENDIX A: MODULE-WISE DESCRIPTION'
$modules = @('Login Screen', 'Signup Screen', 'Forgot Password Screen', 'Home Feed', 'Create Post Screen', 'Search Screen', 'Zone Map Screen', 'Post Card Component', 'Comments Sheet', 'Inline Comments', 'CivicMate Chat', 'Profile Screen', 'Cloudinary Service', 'Firestore Service', 'Gemini Service', 'Theme Controller', 'Top Snackbar', 'Reusable Loaders', 'Scroll To Top Button', 'Glowing Background Logo')
foreach ($module in $modules) {
  H2 $module
  P "The $module module contributes to the overall CivicConnect workflow by handling a focused part of the application. Its design follows the project goal of keeping the user journey simple while maintaining structured data and clear feedback."
  P "From a maintenance point of view, $module can be improved independently as the application grows. Future development may add stronger tests, accessibility labels, role-based variations, and performance optimizations depending on deployment needs."
  P "Implementation notes for $module should be read with the source code and final APK demonstration. During viva or project evaluation, the team can explain the purpose of the module, the data it reads or writes, the validation it performs, and how it contributes to the final user journey."
  PB
}

H1 'APPENDIX B: EXTENDED TEST NOTES'
for ($i = 1; $i -le 35; $i++) {
  P "Extended Test ${i}: Verify a combined workflow involving authentication, navigation, reporting, interaction, data refresh, and permission control. The expected result is that CivicConnect provides visible feedback, preserves data correctly, and prevents unauthorized mutation of another user's report."
}
PB

H1 'APPENDIX C: SCREENSHOT PLACEHOLDERS'
$screens = @('Splash Screen', 'Login Screen', 'Signup Screen', 'Home Feed', 'Create Post Form', 'Multiple Image Upload Preview', 'Post Image Gallery', 'Fullscreen Image Preview', 'Search Screen', 'Zone Map', 'Comment Reply Flow', 'Comment Image Attachment', 'Delete Own Comment', 'Resolution Proof Dialog', 'Resolution Proof Image Preview', 'CivicMate Chat', 'Profile Dashboard', 'Project Information Sheet', 'NorthCap Logo and Signature Section', 'Generated Launcher Icon on Device')
foreach ($screen in $screens) {
  H2 $screen
  Add "<div class='placeholder'>[Insert screenshot of $screen here]</div>"
  P "This screenshot should show the working $screen of CivicConnect. Capture it from the Android emulator or physical APK after final build."
  PB
}

H1 'APPENDIX D: FEATURE VERIFICATION SHEETS'
$featureSheets = @(
  @('Multiple Post Images', 'Verify that users can select more than one gallery image, see thumbnails before upload, remove an unwanted thumbnail, submit the post, and later view all uploaded images in the feed gallery.'),
  @('Camera Image Attachment', 'Verify that a camera-captured image can still be attached to a post and that the old single-image flow remains compatible with the new multi-image storage model.'),
  @('Backward-Compatible Image Fields', 'Verify that old posts using imageUrl still display correctly and new posts using imageUrls display correctly. This protects older Firestore records from breaking after the media upgrade.'),
  @('Fullscreen Image Preview', 'Verify that tapping any post or comment image opens the media on a black fullscreen background with zoom and pan support.'),
  @('Comment Image Upload', 'Verify that users can attach one or more images to a comment, preview them before sending, and remove selected images before upload.'),
  @('Image-Only Comment Support', 'Verify that a comment can be submitted when it has image evidence even if the text field is empty.'),
  @('Comment Reply Metadata', 'Verify that replies store the target comment id and target username so the UI can show who is being replied to.'),
  @('Owner-Only Comment Delete', 'Verify that delete controls appear only for comments created by the current user and that the backend blocks deletion by other users.'),
  @('Resolution Proof Text', 'Verify that marking a post as resolved requires meaningful proof text unless proof photos are attached.'),
  @('Resolution Proof Photos', 'Verify that proof photos upload to Cloudinary and are saved both on the post document and in the automatic resolution proof comment.'),
  @('Resolved Post Locking', 'Verify that resolved posts cannot be changed again after proof is submitted.'),
  @('Search Focus Stability', 'Verify that typing in the search box no longer dismisses the keyboard after every letter because the Firestore stream is cached.'),
  @('Splash on Reload', 'Verify that refreshing the app on login or home route still shows the splash screen before routing to the correct page.'),
  @('Launcher Icon Generation', 'Verify that flutter_launcher_icons uses assets/icon.png and updates Android mipmap launcher files.'),
  @('NorthCap Branding Assets', 'Verify that assets/images/northcap_university_logo.jpg and assets/images/nishu_signature.jpg render in the profile project information section.'),
  @('Location Permission and Weather', 'Verify that Android location permission is requested and temperature loads when permission and location services are available.'),
  @('Owner-Only Resolve', 'Verify that only the original poster can resolve an issue and that other users can only view the status badge.'),
  @('Share Format', 'Verify that shared post text includes title, metadata, link-style identifier, and all photo links.'),
  @('Map Zone Counts', 'Verify that zone active and total counts update from Firestore data.'),
  @('CivicMate Chat Layout', 'Verify that quick recommendations hide after chat begins so they do not interfere with typing.')
)
foreach ($sheet in $featureSheets) {
  H2 $sheet[0]
  P $sheet[1]
  P 'Expected outcome: The feature should work in both debug and release-oriented testing paths without causing analyzer errors, runtime crashes, or unauthorized data mutation.'
  P 'Evidence to attach: Add one screenshot before action, one screenshot after action, and a short note describing the Firestore field or UI state that changed.'
  Add "<div class='placeholder'>[Insert verification screenshot for $($sheet[0]) here]</div>"
  PB
}

Add '</body></html>'

$content = $sb.ToString()
Set-Content -LiteralPath $outHtml -Value $content -Encoding UTF8
Set-Content -LiteralPath $outDoc -Value $content -Encoding UTF8
Get-Item -LiteralPath $outHtml, $outDoc | Select-Object FullName, Length, LastWriteTime
