/// The Wompi environment a set of credentials belongs to.
///
/// Determined by the key prefixes defined in the
/// [official documentation](https://docs.wompi.co/docs/colombia/ambientes-y-llaves/):
/// sandbox keys start with `pub_test_`/`test_integrity_` and production
/// keys with `pub_prod_`/`prod_integrity_`.
enum WompiEnvironment {
  /// Test environment: transactions do not move real money.
  sandbox,

  /// Production environment: transactions are real.
  production,
}
