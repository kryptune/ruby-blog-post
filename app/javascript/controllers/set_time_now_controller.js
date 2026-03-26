import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { prefix: String };

  setNow() {
    const now = new Date();

    // Adjust for local timezone offset to get the correct 'YYYY-MM-DDTHH:MM' string
    const offset = now.getTimezoneOffset() * 60000;
    const localISOTime = new Date(now - offset).toISOString().slice(0, 16);

    // Find the input. If using datetime_field, the ID is usually 'blog_post_published_at'
    const input = document.getElementById(this.prefixValue);
    if (input) {
      input.value = localISOTime;
    }
  }
}
