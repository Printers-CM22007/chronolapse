part of 'dashboard_page.dart';

extension SearchBar on DashboardPageState {
  Container _searchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        key: const Key("searchProjectsTextField"),
        onChanged: _onSearchFieldChanged,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        cursorColor: Theme.of(context).colorScheme.onPrimary,
        decoration: InputDecoration(
            filled: true,
            fillColor: blackColour,
            hintText: "Search Project",
            hintStyle:
                TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            hoverColor: Theme.of(context).colorScheme.onPrimary,
            prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  DashboardPageIcons.search,
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none)),
      ),
    );
  }
}
