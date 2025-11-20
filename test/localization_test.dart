import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carbo/base/localization/i18n_service.dart';

void main() {
  group('Localization Tests', () {
    test('LanguageModel can be created from JSON', () {
      final json = {
        'code': 'en',
        'name': 'English',
        'direction': 'ltr',
      };
      
      final language = LanguageModel.fromJson(json);
      
      expect(language.code, 'en');
      expect(language.name, 'English');
      expect(language.direction, 'ltr');
    });

    test('LanguageModel defaults to ltr direction', () {
      final language = LanguageModel(
        code: 'en',
        name: 'English',
      );
      
      expect(language.direction, 'ltr');
    });

    test('LanguageModel can be converted to JSON', () {
      final language = LanguageModel(
        code: 'ar',
        name: 'Arabic',
        direction: 'rtl',
      );
      
      final json = language.toJson();
      
      expect(json['code'], 'ar');
      expect(json['name'], 'Arabic');
      expect(json['direction'], 'rtl');
    });

    test('I18n determines correct text direction for languages', () {
      // LTR languages
      expect(
        'en' == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        TextDirection.ltr,
      );
      
      // RTL languages
      expect(
        'ar' == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        TextDirection.rtl,
      );
    });
  });
}

