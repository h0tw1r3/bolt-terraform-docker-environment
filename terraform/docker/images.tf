resource "docker_image" "map" {
  for_each = {
    for image in local.need_images:
    image => lookup(local.images, image)
  }

  name = each.value.name
  build {
    context = try(dirname(each.value.dockerfile), ".")
    dockerfile = try(basename(each.value.dockerfile), "Dockerfile")
    build_args = {
      IMAGE_REPO : each.value.repo
      IMAGE_TAG : each.value.tag
    }
    target = each.key
  }
  keep_locally = true
}
