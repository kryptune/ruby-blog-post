import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { prefix: String };
  setNow() {
    const date = new Date();
    const offset = -8; // hours
    const now = new Date(date.getTime() + offset * 3600000);

    const prefix = this.prefixValue;
    document.getElementById(`${prefix}_1i`).value = now.getFullYear();
    document.getElementById(`${prefix}_2i`).value = now.getMonth() + 1;
    document.getElementById(`${prefix}_3i`).value = now.getDate();
    document.getElementById(`${prefix}_4i`).value =
      now.getHours() < 10 ? `0${now.getHours()}` : now.getHours();
    document.getElementById(`${prefix}_5i`).value =
      now.getMinutes() < 10 ? `0${now.getMinutes()}` : now.getMinutes();
  }
}
