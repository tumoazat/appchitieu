# AI Advice Screen

## Overview
This module provides AI-powered financial advice based on transaction analysis.

## Files

### ai_advice_screen.dart
Main screen displaying AI financial advice:
- ConsumerStatefulWidget for state management
- Loads transactions for current month
- Analyzes spending patterns with AiAdviceService
- Shows budget progress and personalized advice cards
- Loading states with shimmer effects
- Refresh functionality with "Phân tích lại" button

### widgets/advice_card.dart
Individual advice card component:
- Displays AdviceItem from AiAdviceService
- Color-coded left border (green/blue/yellow/orange/red)
- Emoji + title + message layout
- Highlights important numbers in bold
- Animated entrance with flutter_animate (fadeIn + slideY)

### widgets/budget_progress.dart
Budget progress indicator:
- Shows monthly budget usage with progress bar
- Color changes based on usage: green (<70%), yellow (70-90%), red (>90%)
- Displays three metrics: Spent / Budget / Remaining
- Animated transitions

## Dependencies
- flutter_riverpod: State management
- flutter_animate: Entrance animations
- AiAdviceService: Transaction analysis
- Providers: transactionsStreamProvider, monthlyBudgetProvider

## Usage
```dart
import 'package:flutter/material.dart';
import 'presentation/ai_advice/ai_advice_screen.dart';

// In your router or navigation:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const AiAdviceScreen()),
);
```

## Features
- Real-time transaction analysis
- Budget tracking and warnings
- Category spending insights
- Savings suggestions
- Spending habits analysis
- Month-over-month comparisons
- Vietnamese localization
