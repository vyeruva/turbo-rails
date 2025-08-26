import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  remove() {
    console.log('removing element')
    this.element.remove()
  }
}