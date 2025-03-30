part of 'dashboard_page.dart';

extension ImportButton on DashboardPageState {
  Container _importButton() {
    return Container(
      width: 120,
      padding: const EdgeInsets.only(right: 25),
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inverseSurface),
        // TODO: Ignored because intentionally disabled - WIP
        onPressed: () {}, // coverage:ignore-line
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              DashboardPageIcons.import,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            Text(
              "Import",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            )
          ],
        ),
      ),
    );
  }
}
