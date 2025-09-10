# Copilot Instructions for SelfMuteRadio Plugin

## Repository Overview

This repository contains the **SelfMuteRadio** SourcePawn plugin for SourceMod, which allows players to selectively mute radio sounds and text messages in Source engine games (particularly Counter-Strike). The plugin provides individual client preferences that persist across sessions using SourceMod's client cookies system.

### Plugin Functionality
- **Radio Sound Muting**: Players can disable radio sound effects while keeping text messages
- **Radio Text Muting**: Players can disable radio text messages while keeping sound effects  
- **Persistent Settings**: Player preferences are saved using SourceMod cookies
- **Menu Interface**: In-game menu accessible via `sm_smradio` command
- **Message Filtering**: Hooks `RadioText` and `SendAudio` user messages to filter content per-player

## Technical Environment

### Core Technologies
- **Language**: SourcePawn (.sp files)
- **Platform**: SourceMod 1.11+ (currently targeting 1.11.0-git6917)
- **Build System**: SourceKnight (dependency management and compilation)
- **Compiler**: SourcePawn Compiler (spcomp) via SourceKnight
- **CI/CD**: GitHub Actions with automated building and releases

### Dependencies
- `sourcemod` - Core SourceMod framework  
- `sdktools` - SDK tools for game interaction
- `clientprefs` - Client preference/cookie system
- `multicolors` - Enhanced chat color support

### Build Process
1. **SourceKnight Configuration**: `sourceknight.yaml` defines dependencies and build targets
2. **Compilation**: GitHub Actions uses `maxime1907/action-sourceknight@v1` 
3. **Packaging**: Compiled `.smx` files are packaged for release
4. **Release**: Automatic tagging and release creation on main branch

## Project Structure

```
/
├── .github/
│   ├── workflows/ci.yml     # CI/CD pipeline
│   └── dependabot.yml       # Dependency updates
├── addons/sourcemod/scripting/
│   └── SelfMuteRadio.sp     # Main plugin source
├── sourceknight.yaml        # Build configuration
└── .gitignore              # Git ignore rules
```

## Code Style & Architecture

### Plugin Architecture
- **Event-Driven**: Uses SourceMod's callback system (OnPluginStart, OnClientCookiesCached, etc.)
- **Hook-Based Filtering**: Intercepts user messages before they reach clients
- **Cookie Storage**: Binary format storing sound/text preferences as "01" strings
- **Menu System**: Custom menu with real-time preference display

### Coding Standards Applied
- ✅ `#pragma semicolon 1` and `#pragma newdecls required`
- ✅ Global variables prefixed with `g_` (e.g., `g_bSelfMuteRadioSound`)
- ✅ PascalCase for functions (`OnPluginStart`, `DisplayCookieMenu`)
- ✅ camelCase for local variables and parameters
- ✅ Tab indentation (4 spaces)
- ✅ Descriptive function and variable names

### Code Quality Issues to Address
When modifying this code, be aware of these patterns that should be modernized:
- **Handle Management**: Replace `CloseHandle()` calls with `delete` operator (lines 315, 334)
- **Memory Management**: Use modern methodmap APIs where possible
- **Error Handling**: Ensure all API calls have proper error checking

## Key Components

### Global Variables
- `g_hSelfMuteRadioCookie`: Handle to client preference cookie
- `g_bSelfMuteRadioSound[MAXPLAYERS + 1]`: Per-client sound muting state
- `g_bSelfMuteRadioText[MAXPLAYERS + 1]`: Per-client text muting state
- `g_bLate`: Late load detection flag

### Core Functions
- `Hook_UserMessageSendAudio()`: Filters radio sound messages
- `Hook_UserMessageRadioText()`: Filters radio text messages  
- `DisplayCookieMenu()`: Shows preference menu to players
- `ReadClientCookies()`/`SetClientCookies()`: Preference persistence

### Message Flow
1. Game sends radio message to all players
2. Plugin hooks capture the message before delivery
3. Plugin filters recipient list based on individual preferences
4. Message is re-sent only to players who haven't muted that type

## Development Guidelines

### Local Development Setup
```bash
# Note: SourceKnight is not typically installed locally
# Development usually relies on CI/CD pipeline for building
# For syntax checking, ensure you have SourcePawn includes available
```

### Testing Strategy
- **Manual Testing**: Load plugin on test server, verify menu functionality
- **Radio Testing**: Test both sound and text filtering with multiple players
- **Persistence Testing**: Verify settings survive server restarts and reconnections
- **Late Load Testing**: Ensure plugin works when loaded on active server

### Common Modification Patterns

#### Adding New Preferences
1. Add new global boolean array: `g_bNewFeature[MAXPLAYERS + 1]`
2. Update cookie reading/writing to handle additional data
3. Add menu option in `DisplayCookieMenu()` and `MenuHandler_SelfMuteRadio()`
4. Implement filtering logic in appropriate hook

#### Message Hook Modifications
- Always check message type before processing
- Maintain player array filtering pattern for performance
- Use `RequestFrame()` for complex message reconstruction
- Handle edge cases (disconnected players, invalid data)

### Build & Release Process

#### GitHub Actions Workflow
1. **Build**: Compiles plugin using SourceKnight action
2. **Package**: Creates distribution archive
3. **Tag**: Auto-tags latest builds from main branch  
4. **Release**: Publishes GitHub releases with compiled binaries

#### Version Management
- Version defined in plugin info block (currently 1.2.1)
- Follow semantic versioning for releases
- Update version in plugin source when making releases

## Performance Considerations

### Critical Performance Areas
- **Message Hooks**: Called frequently during gameplay, minimize processing
- **Player Loops**: Optimize player iteration in filtering functions
- **Memory Allocation**: Avoid unnecessary dynamic allocations in hot paths
- **String Operations**: Cache string operations where possible

### Optimization Patterns Used
- Pre-filter message types before expensive processing
- Use frame-delayed processing for complex message reconstruction
- Efficient player array management in hooks
- Minimal string parsing in performance-critical sections

## Debugging & Troubleshooting

### Common Issues
- **Message Hooks Not Working**: Verify game supports RadioText/SendAudio messages
- **Preferences Not Saving**: Check cookie system is enabled on server
- **Late Load Problems**: Ensure cookie caching check in OnPluginStart
- **Memory Leaks**: Verify all DataPack/Handle objects are properly cleaned up

### Debugging Tools
- SourceMod's built-in profiler for performance analysis
- Server console logging for message flow debugging
- Client preference examination via sm_cookie commands

## Security Considerations

### Input Validation
- Cookie data is validated before parsing (length checks)
- Player indices are validated before array access
- Message content is not modified, only filtered

### Safe Coding Practices  
- All player arrays are bounds-checked
- Handle validity confirmed before operations
- No direct string manipulation of game messages

## Future Enhancement Areas

### Potential Improvements
- **Granular Filtering**: Allow filtering specific radio command types
- **Team-Based Options**: Separate preferences for team vs all radio
- **Admin Controls**: Server-side radio management features
- **Performance Metrics**: Built-in performance monitoring

### API Compatibility
- Maintain backwards compatibility with existing cookie format
- Consider migration strategy for preference format changes
- Ensure SourceMod version compatibility across updates

---

When working on this codebase, prioritize minimal, surgical changes that maintain the existing architecture while following modern SourcePawn best practices. Always test message filtering functionality thoroughly, as it directly impacts gameplay experience.