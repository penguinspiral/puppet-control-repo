class role::seed() {
  # WONT BOOTSTRAP BE PRESENT FOR ALL NODES?! DO WE WANT TO RUN IT ONCE AT END OF PRESEEED?!
  include profile::bootstrap
}
