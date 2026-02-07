import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/i18n/translations.g.dart';

void main() {
  group('Translation Keys - API Errors', () {
    test('English error translations are accessible via global t variable', () {
      // Set locale to English
      LocaleSettings.setLocale(AppLocale.en);
      
      // Verify all error keys are accessible
      expect(t.errors.networkError, 'Connection error. Please check your internet connection.');
      expect(t.errors.timeoutError, 'Request timeout. Please try again.');
      expect(t.errors.serverError, 'Server error occurred. Please try again later.');
      expect(t.errors.parsingError, 'Failed to process server response.');
      expect(t.errors.genericError, 'An unexpected error occurred.');
      expect(t.errors.loadEventsError, 'Failed to load events.');
      expect(t.errors.loadFavoritesError, 'Failed to load favorites.');
      expect(t.errors.toggleFavoriteError, 'Failed to update favorite.');
    });

    test('Czech error translations are accessible via global t variable', () {
      // Set locale to Czech
      LocaleSettings.setLocale(AppLocale.cs);
      
      // Verify all error keys are accessible
      expect(t.errors.networkError, 'Chyba připojení. Zkontrolujte prosím své internetové připojení.');
      expect(t.errors.timeoutError, 'Vypršel časový limit požadavku. Zkuste to prosím znovu.');
      expect(t.errors.serverError, 'Došlo k chybě serveru. Zkuste to prosím později.');
      expect(t.errors.parsingError, 'Nepodařilo se zpracovat odpověď serveru.');
      expect(t.errors.genericError, 'Došlo k neočekávané chybě.');
      expect(t.errors.loadEventsError, 'Nepodařilo se načíst události.');
      expect(t.errors.loadFavoritesError, 'Nepodařilo se načíst oblíbené.');
      expect(t.errors.toggleFavoriteError, 'Nepodařilo se aktualizovat oblíbené.');
    });

    test('Spanish error translations are accessible via global t variable', () {
      // Set locale to Spanish
      LocaleSettings.setLocale(AppLocale.es);
      
      // Verify all error keys are accessible
      expect(t.errors.networkError, 'Error de conexión. Por favor, verifica tu conexión a internet.');
      expect(t.errors.timeoutError, 'Tiempo de espera agotado. Por favor, inténtalo de nuevo.');
      expect(t.errors.serverError, 'Error del servidor. Por favor, inténtalo más tarde.');
      expect(t.errors.parsingError, 'Error al procesar la respuesta del servidor.');
      expect(t.errors.genericError, 'Ocurrió un error inesperado.');
      expect(t.errors.loadEventsError, 'Error al cargar eventos.');
      expect(t.errors.loadFavoritesError, 'Error al cargar favoritos.');
      expect(t.errors.toggleFavoriteError, 'Error al actualizar favorito.');
    });
  });
}
