resource "docker_image" "ubuntu_2004" {
  name = "at.local/ubuntu:20.04"
  build {
    context = "."
    build_args = {
      IMAGE_REPO : "library/ubuntu"
      IMAGE_TAG : "20.04"
    }
    target = "ubuntu-20.04"
  }
  keep_locally = true
}

resource "docker_image" "ubuntu_1804" {
  name = "at.local/ubuntu:18.04"
  build {
    context = "."
    build_args = {
      IMAGE_REPO : "library/ubuntu"
      IMAGE_TAG : "18.04"
    }
    target = "ubuntu-18.04"
  }
  keep_locally = true
}

resource "docker_image" "ubuntu_1604" {
  name = "at.local/ubuntu:16.04"
  build {
    context = "."
    build_args = {
      IMAGE_REPO : "library/ubuntu"
      IMAGE_TAG : "16.04"
    }
    target = "ubuntu-16.04"
  }
  keep_locally = true
}
