# STROT macOS VoiceOver and launcher-icon audit

Date: 26 August 2026  
Surface: Flutter macOS debug application  
Account/state: authenticated mock client, Oak Residence

## Outcome

The assisted VoiceOver pass reached the sign-in and authenticated client-workspace states. The user confirmed hearing the complete announcement during the authenticated traversal.

The initial `content is empty` announcement was isolated to the non-interactive `Oak Residence` title group. Exiting that group continued into the application toolbar, so it did not block access to the workspace. The first toolbar control was then exposed only as a generic button. The four toolbar actions were updated with explicit semantic button labels.

After rebuilding, the native macOS accessibility tree exposed:

- Organization details
- Profile and contact details
- Synchronisation status
- Account security

The Flutter launcher artwork was also replaced for Android, iOS/iPadOS, macOS, and Windows with the approved STROT mark on the approved cream background. Launch Services and the Dock were refreshed after the rebuilt macOS application bundle was registered.

## Evidence

1. VoiceOver active on authenticated workspace: `06-authenticated-voiceover-active.png`
2. Title-group interaction and empty leaf: `07-authenticated-group-interaction.png`
3. Traversal continues to the first toolbar control: `08-after-exit-title-group-next.png`
4. Rebuilt sign-in surface: `09-rebuilt-strot-icon-sign-in.png`
5. Refreshed Dock showing the STROT launcher icon: `10-dock-icon-refresh.png`
6. Rebuilt authenticated workspace: `11-rebuilt-authenticated.png`

## Verification

- User-confirmed complete VoiceOver announcement.
- Native macOS accessibility-tree inspection confirmed all four toolbar labels.
- Flutter widget test asserts all four semantic labels.
- Rebuilt `AppIcon.icns` was extracted and visually inspected; it contains the approved STROT mark.
- Generated iOS app icons have no alpha channel.
- The Windows ICO contains four embedded PNG sizes (16, 32, 48, and 256 pixels).

## Health and limits

This pass verifies the tested macOS sign-in, client workspace entry, toolbar labels, and launcher icon. It is not a claim of complete WCAG or platform-wide accessibility compliance. TalkBack on Android and full role-by-role screen-reader journeys remain separate human-device checks.
