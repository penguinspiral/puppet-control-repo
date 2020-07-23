class profile::bootstrap(
  Boolean $seed = false,
) {
  notice("Profile bootstrap.pp included!")

  include profile::bootstrap::node

  # if ($seed) {
  #   include profile::bootstrap::seed
  # }

}
