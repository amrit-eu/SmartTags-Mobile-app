/// Request body for `POST /api/oceanops/data/enriched-goos-passport/search`.
/// Mirrors the Gateway (NestJS) `PassportFilterDto`.
class PassportFilterDto {
  /// Creates a [PassportFilterDto].
  const PassportFilterDto({
    this.filters,
    this.ptfIds,
    this.internalIds,
    this.cachedSince,
    this.paginationEnabled,
    this.limit,
    this.offset,
  });

  /// Free-form filter fields (e.g. `programCodes`, `networkCodes`, `reportingStatusCodes`).
  final Map<String, dynamic>? filters;

  /// Platform identifiers to search for.
  final List<String>? ptfIds;

  /// Internal identifiers to search for.
  final List<String>? internalIds;

  /// Only return passports cached/updated since this ISO-8601 date/time.
  final String? cachedSince;

  /// Whether pagination is enabled for this search.
  final bool? paginationEnabled;

  /// Maximum number of results to return, when [paginationEnabled] is true.
  final int? limit;

  /// Number of results to skip, when [paginationEnabled] is true.
  final int? offset;

  /// Serializes to the JSON body expected by the Gateway, omitting unset fields.
  Map<String, dynamic> toJson() => {
    if (filters != null) 'filters': filters,
    if (ptfIds != null) 'ptfIds': ptfIds,
    if (internalIds != null) 'internalIds': internalIds,
    if (cachedSince != null) 'cachedSince': cachedSince,
    if (paginationEnabled != null) 'paginationEnabled': paginationEnabled,
    if (limit != null) 'limit': limit,
    if (offset != null) 'offset': offset,
  };
}
