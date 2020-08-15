class profile::bootstrap(
  Boolean $seed = false,
){
  include profile::bootstrap::node
  if ($seed) {
    include profile::bootstrap::seed
  }
}
