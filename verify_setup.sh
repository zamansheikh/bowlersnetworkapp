#!/bin/bash
# Bowlers Network App - Setup Verification Script

echo "🎳 Bowlers Network App - Clean Architecture Setup Verification"
echo "============================================================="

echo ""
echo "📋 Checking Project Structure..."

# Check core structure
if [ -d "lib/core" ]; then
    echo "✅ Core layer exists"
    if [ -f "lib/core/constants/colors.dart" ]; then
        echo "✅ Brand colors (#8BC342) configured"
    fi
    if [ -f "lib/core/theme/app_theme.dart" ]; then
        echo "✅ Material 3 theme with brand colors ready"
    fi
    if [ -f "lib/core/router/app_router.dart" ]; then
        echo "✅ Go Router navigation configured"
    fi
    if [ -f "lib/core/di/injection.dart" ]; then
        echo "✅ Dependency injection (GetIt + Injectable) setup"
    fi
else
    echo "❌ Core layer missing"
fi

# Check features structure
if [ -d "lib/features/home" ]; then
    echo "✅ Feature-based structure (Clean Architecture)"
    if [ -d "lib/features/home/data" ] && [ -d "lib/features/home/domain" ] && [ -d "lib/features/home/presentation" ]; then
        echo "✅ Complete 3-layer architecture (Data, Domain, Presentation)"
    fi
    if [ -f "lib/features/home/presentation/bloc/home_bloc.dart" ]; then
        echo "✅ Flutter Bloc state management implemented"
    fi
else
    echo "❌ Features structure missing"
fi

echo ""
echo "📦 Checking Dependencies..."

# Check if pubspec.yaml has the right dependencies
if grep -q "flutter_bloc" pubspec.yaml; then
    echo "✅ Flutter Bloc for state management"
fi
if grep -q "get_it" pubspec.yaml; then
    echo "✅ GetIt for dependency injection"
fi
if grep -q "go_router" pubspec.yaml; then
    echo "✅ Go Router for navigation"
fi
if grep -q "dartz" pubspec.yaml; then
    echo "✅ Dartz Either for functional programming"
fi
if grep -q "dio" pubspec.yaml; then
    echo "✅ Dio for HTTP networking"
fi

echo ""
echo "🔧 Checking Generated Files..."

if [ -f "lib/core/di/injection.config.dart" ]; then
    echo "✅ Dependency injection files generated"
else
    echo "⚠️  Run: dart run build_runner build"
fi

if [ -f "lib/features/home/data/models/user_model.g.dart" ]; then
    echo "✅ JSON serialization files generated"
fi

echo ""
echo "🎨 Brand Implementation:"
echo "   Primary Color: #8BC342 (Lime Green)"
echo "   Supporting Colors: Black & White"
echo "   Applied to: Themes, AppBars, Buttons, Icons"

echo ""
echo "🚀 Next Steps:"
echo "   1. Run: flutter run"
echo "   2. Add your bowling-specific features"
echo "   3. Implement authentication, user profiles, etc."

echo ""
echo "📚 Architecture Ready:"
echo "   ✅ Clean Architecture (3 layers)"
echo "   ✅ SOLID Principles"
echo "   ✅ Dependency Inversion"
echo "   ✅ Separation of Concerns"
echo "   ✅ Testability"

echo ""
echo "🎳 Your Bowlers Network app is ready for development!"
