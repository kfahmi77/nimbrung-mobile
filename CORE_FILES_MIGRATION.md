# Migration Summary: Core Files Status

## ✅ Files Still in Use:

### Models (Still Used by Other Features)

- `lib/core/models/api_error.dart` - Used by daily-readings feature
- `lib/core/models/base_response.dart` - Used by daily-readings feature
- `lib/core/models/meta.dart` - Used by base_response
- `lib/core/models/profile_update_dto.dart` - Used by register_update_page (can be migrated)

### Constants & Utils

- `lib/core/constants/api_constant.dart` - Used by daily-readings feature
- `lib/core/errors/exceptions.dart` - Used by daily-readings feature
- `lib/core/errors/failures.dart` - Used by multiple features
- `lib/core/usecases/usecase.dart` - Used by Clean Architecture
- `lib/core/utils/logger.dart` - Used throughout the app
- `lib/core/config/supabase_config.dart` - Used by auth data source

## ❌ Files Ready for Removal (After Migration):

### Auth-Related (Replaced by Clean Architecture)

- `lib/core/providers/auth_provider.dart` - Replace with new auth providers
- `lib/core/services/auth_service.dart` - Replace with repository pattern
- `lib/core/models/user_model.dart` - Moved to features/auth/data/models/
- `lib/core/models/preference_model.dart` - Moved to features/auth/data/models/
- `lib/core/models/register_dto.dart` - Replace with use case params

## 🔄 Migration Tasks:

1. **Update login_page.dart** - Use loginNotifierProvider instead of loginProvider
2. **Update register_update_page.dart** - Use profileUpdateNotifierProvider
3. **Migrate profile_update_dto** - Move to features/auth if needed
4. **Clean up imports** - Remove references to old auth files

## 📁 Folder Structure After Cleanup:

```
lib/core/
├── config/           # Supabase config
├── constants/        # API constants
├── error/           # New Clean Architecture errors
├── errors/          # Legacy errors (still used by daily-readings)
├── models/          # Only non-auth models (api_error, base_response, meta)
├── usecases/        # Base use case class
└── utils/           # Logger and extensions
```

## 🎯 Next Steps:

1. Finish migrating login and register-update pages
2. Remove unused auth-related files
3. Update imports throughout the app
4. Consider migrating daily-readings to Clean Architecture
5. Remove duplicate error handling (error/ vs errors/)
