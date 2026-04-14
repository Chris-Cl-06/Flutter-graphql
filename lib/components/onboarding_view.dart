import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';

class OnBoardingView extends StatelessWidget {
  final VoidCallback onFinish;

  const OnBoardingView({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryColor = Color(0xFF2196F3);
    // Obtenemos el ancho para asegurar el centrado
    double screenWidth = MediaQuery.of(context).size.width;

    return OnBoardingSlider(
      headerBackgroundColor: Colors.black,
      finishButtonText: 'Start',
      onFinish: onFinish,
      finishButtonStyle: const FinishButtonStyle(
        backgroundColor: kPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      skipTextButton: const Text(
        'Skip',
        style: TextStyle(
          fontSize: 16,
          color: kPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      background: [
        // Usamos un Container con ancho total para forzar el centrado real
        _buildBackgroundImage('../assets/images/slide_1.png', screenWidth),
        _buildBackgroundImage('../assets/images/slide_2.png', screenWidth),
        _buildBackgroundImage('../assets/images/slide_3.png', screenWidth),
        _buildBackgroundImage('../assets/images/slide_1.png', screenWidth),
        _buildBackgroundImage('../assets/images/slide_2.png', screenWidth),
      ],
      controllerColor: kPrimaryColor,
      totalPage: 5,
      speed: 1.8,
      pageBodies: [
        _buildPageBody(
          title: 'Bienvenido a Tag Inspector',
          description:
              'Explora el nuevo estándar en auditoría RFID. Hemos rediseñado la interfaz para ofrecerte una experiencia más fluida, intuitiva y potente en la gestión de tus activos.',
        ),
        _buildPageBody(
          title: 'Escaneo de Alta Precisión',
          description:
              'Optimiza tus inventarios con nuestro motor de lectura mejorado. Capaz de procesar cientos de tags por segundo con una tasa de error prácticamente nula.',
        ),
        _buildPageBody(
          title: 'Búsqueda Inteligente Geiger',
          description:
              'Localiza tags específicos mediante indicadores visuales y sonoros. La intensidad de la señal te guiará directamente hacia el ítem que estás buscando.',
        ),
        _buildPageBody(
          title: 'Edición y Bloqueo Seguro',
          description:
              'Gestiona la memoria de tus tags en tiempo real. Escribe nuevos datos de forma segura o utiliza las funciones de bloqueo (Lock) y borrado (Kill) permanente.',
        ),
        _buildPageBody(
          context: context, // Pasamos el contexto para el reset
          isLastPage: true, // Marcamos que es la última
          title: 'Analítica en la Nube',
          description:
              'Exporta tus informes en múltiples formatos y sincroniza tus sesiones de lectura con el panel administrativo para un control total desde cualquier lugar.',
        ),
      ],
    );
  }

  // Función auxiliar para centrar la imagen de fondo correctamente
  Widget _buildBackgroundImage(String assetPath, double width) {
    return Container(
      width: width, // Ocupa todo el ancho de la pantalla
      alignment: Alignment.center, // Alinea el hijo al centro absoluto
      child: Image.asset(assetPath, height: 400, fit: BoxFit.contain),
    );
  }

  Widget _buildPageBody({
    required String title,
    required String description,
    bool isLastPage = false,
    BuildContext? context,
  }) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 480),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF212121),
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          // Botón de reset solo en la última página
          if (isLastPage && context != null) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                // Reinicia el tutorial recargando la vista
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnBoardingView(onFinish: onFinish),
                  ),
                );
              },
              icon: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
              label: const Text(
                'Resetear Tutorial',
                style: TextStyle(color: Color(0xFF2196F3)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
