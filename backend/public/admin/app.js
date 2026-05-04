const advertsApiBase = "/api/v1/admin/adverts";
const usersApiBase = "/api/v1/admin/users";
const adminKeyStorage = "al_shihab_admin_key";

const state = {
  adverts: [],
  users: [],
  selectedPlacement: "",
  userSearch: "",
};

const els = {
  adminKey: document.querySelector("#adminKey"),
  saveKeyButton: document.querySelector("#saveKeyButton"),
  refreshButton: document.querySelector("#refreshButton"),
  newButton: document.querySelector("#newButton"),
  resetButton: document.querySelector("#resetButton"),
  cancelEditButton: document.querySelector("#cancelEditButton"),
  placementFilter: document.querySelector("#placementFilter"),
  advertsList: document.querySelector("#advertsList"),
  statusText: document.querySelector("#statusText"),
  totalCount: document.querySelector("#totalCount"),
  activeCount: document.querySelector("#activeCount"),
  offerCount: document.querySelector("#offerCount"),
  toast: document.querySelector("#toast"),
  form: document.querySelector("#advertForm"),
  formTitle: document.querySelector("#formTitle"),
  submitButton: document.querySelector("#submitButton"),
  advertId: document.querySelector("#advertId"),
  slug: document.querySelector("#slug"),
  title: document.querySelector("#title"),
  titleAr: document.querySelector("#titleAr"),
  subtitle: document.querySelector("#subtitle"),
  subtitleAr: document.querySelector("#subtitleAr"),
  imageUrl: document.querySelector("#imageUrl"),
  ctaLabel: document.querySelector("#ctaLabel"),
  ctaLabelAr: document.querySelector("#ctaLabelAr"),
  placement: document.querySelector("#placement"),
  campaignType: document.querySelector("#campaignType"),
  discountPercent: document.querySelector("#discountPercent"),
  productId: document.querySelector("#productId"),
  categoryId: document.querySelector("#categoryId"),
  active: document.querySelector("#active"),
  priority: document.querySelector("#priority"),
  startsAt: document.querySelector("#startsAt"),
  endsAt: document.querySelector("#endsAt"),
  imagePreview: document.querySelector("#imagePreview"),
  previewTitle: document.querySelector("#previewTitle"),
  previewMeta: document.querySelector("#previewMeta"),
  refreshUsersButton: document.querySelector("#refreshUsersButton"),
  userSearch: document.querySelector("#userSearch"),
  usersCount: document.querySelector("#usersCount"),
  activeUsersCount: document.querySelector("#activeUsersCount"),
  verifiedUsersCount: document.querySelector("#verifiedUsersCount"),
  usersList: document.querySelector("#usersList"),
  userForm: document.querySelector("#userForm"),
  userId: document.querySelector("#userId"),
  userName: document.querySelector("#userName"),
  userEmail: document.querySelector("#userEmail"),
  userPhone: document.querySelector("#userPhone"),
  userActive: document.querySelector("#userActive"),
  userVerified: document.querySelector("#userVerified"),
  cancelUserEditButton: document.querySelector("#cancelUserEditButton"),
};

function init() {
  els.adminKey.value =
    localStorage.getItem(adminKeyStorage) || "local-admin-key";
  setDefaultDates();
  bindEvents();
  updatePreview();
  loadAdverts();
  loadUsers();
}

function bindEvents() {
  els.saveKeyButton.addEventListener("click", () => {
    localStorage.setItem(adminKeyStorage, els.adminKey.value.trim());
    showToast("تم حفظ مفتاح الإدارة");
    loadAdverts();
    loadUsers();
  });

  els.refreshButton.addEventListener("click", loadAdverts);
  els.newButton.addEventListener("click", resetForm);
  els.resetButton.addEventListener("click", resetForm);
  els.cancelEditButton.addEventListener("click", resetForm);
  els.placementFilter.addEventListener("change", () => {
    state.selectedPlacement = els.placementFilter.value;
    render();
  });

  els.form.addEventListener("submit", saveAdvert);
  els.refreshUsersButton.addEventListener("click", loadUsers);
  els.userSearch.addEventListener("input", () => {
    state.userSearch = els.userSearch.value.trim().toLowerCase();
    renderUsers();
  });
  els.userForm.addEventListener("submit", saveUser);
  els.cancelUserEditButton.addEventListener("click", resetUserForm);
  [
    els.titleAr,
    els.subtitleAr,
    els.imageUrl,
    els.placement,
    els.campaignType,
    els.discountPercent,
  ].forEach((el) => el.addEventListener("input", updatePreview));
}

async function request(baseUrl, path = "", options = {}) {
  const adminKey = els.adminKey.value.trim();
  const response = await fetch(`${baseUrl}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      "X-Admin-Key": adminKey,
      ...(options.headers || {}),
    },
  });
  const payload = await response.json().catch(() => null);
  if (!response.ok) {
    const message = payload?.message || "تعذر تنفيذ العملية";
    throw new Error(Array.isArray(message) ? message.join("، ") : message);
  }
  return payload;
}

async function loadAdverts() {
  setStatus("جاري التحميل");
  try {
    const payload = await request(advertsApiBase);
    state.adverts = payload.data || [];
    render();
    setStatus("تم التحديث");
  } catch (error) {
    setStatus("تعذر التحميل");
    showToast(error.message);
  }
}

async function saveAdvert(event) {
  event.preventDefault();
  const id = els.advertId.value;
  const body = advertFromForm();

  setStatus("جاري الحفظ");
  try {
    await request(advertsApiBase, id ? `/${id}` : "", {
      method: id ? "PATCH" : "POST",
      body: JSON.stringify(body),
    });
    showToast(id ? "تم تحديث الإعلان" : "تم إنشاء الإعلان");
    resetForm();
    await loadAdverts();
  } catch (error) {
    setStatus("تعذر الحفظ");
    showToast(error.message);
  }
}

async function deleteAdvert(id) {
  const advert = state.adverts.find((item) => item.id === id);
  const confirmed = window.confirm(
    `هل تريد حذف الإعلان "${advert?.title_ar || id}"؟`,
  );
  if (!confirmed) return;

  setStatus("جاري الحذف");
  try {
    await request(advertsApiBase, `/${id}`, { method: "DELETE" });
    showToast("تم حذف الإعلان");
    await loadAdverts();
  } catch (error) {
    setStatus("تعذر الحذف");
    showToast(error.message);
  }
}

async function toggleAdvert(id) {
  const advert = state.adverts.find((item) => item.id === id);
  if (!advert) return;

  try {
    await request(advertsApiBase, `/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ active: !advert.active }),
    });
    showToast(advert.active ? "تم تعطيل الإعلان" : "تم تفعيل الإعلان");
    await loadAdverts();
  } catch (error) {
    showToast(error.message);
  }
}

async function loadUsers() {
  try {
    const payload = await request(usersApiBase);
    state.users = payload.data || [];
    renderUsers();
  } catch (error) {
    showToast(error.message);
  }
}

async function saveUser(event) {
  event.preventDefault();
  const id = els.userId.value;
  if (!id) return;

  try {
    await request(usersApiBase, `/${id}`, {
      method: "PATCH",
      body: JSON.stringify(userFromForm()),
    });
    showToast("تم تحديث المستخدم");
    resetUserForm();
    await loadUsers();
  } catch (error) {
    showToast(error.message);
  }
}

async function toggleUser(id, field) {
  const user = state.users.find((item) => item.id === id);
  if (!user) return;

  try {
    await request(usersApiBase, `/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ [field]: !user[field] }),
    });
    showToast("تم تحديث حالة المستخدم");
    await loadUsers();
  } catch (error) {
    showToast(error.message);
  }
}

async function deleteUser(id) {
  const user = state.users.find((item) => item.id === id);
  const confirmed = window.confirm(
    `هل تريد حذف المستخدم "${user?.name || id}"؟`,
  );
  if (!confirmed) return;

  try {
    await request(usersApiBase, `/${id}`, { method: "DELETE" });
    showToast("تم حذف المستخدم");
    resetUserForm();
    await loadUsers();
  } catch (error) {
    showToast(error.message);
  }
}

function advertFromForm() {
  const discountValue = els.discountPercent.value.trim();
  return {
    slug: els.slug.value.trim(),
    title: els.title.value.trim(),
    title_ar: els.titleAr.value.trim(),
    subtitle: els.subtitle.value.trim(),
    subtitle_ar: els.subtitleAr.value.trim(),
    image_url: els.imageUrl.value.trim(),
    cta_label: els.ctaLabel.value.trim(),
    cta_label_ar: els.ctaLabelAr.value.trim(),
    placement: els.placement.value,
    campaign_type: els.campaignType.value,
    discount_percent: discountValue === "" ? null : Number(discountValue),
    product_id: emptyToNull(els.productId.value),
    category_id: emptyToNull(els.categoryId.value),
    active: els.active.checked,
    priority: Number(els.priority.value),
    starts_at: toIso(els.startsAt.value),
    ends_at: toIso(els.endsAt.value),
  };
}

function editAdvert(id) {
  const advert = state.adverts.find((item) => item.id === id);
  if (!advert) return;

  els.advertId.value = advert.id;
  els.slug.value = advert.slug;
  els.title.value = advert.title;
  els.titleAr.value = advert.title_ar;
  els.subtitle.value = advert.subtitle;
  els.subtitleAr.value = advert.subtitle_ar;
  els.imageUrl.value = advert.image_url;
  els.ctaLabel.value = advert.cta_label;
  els.ctaLabelAr.value = advert.cta_label_ar;
  els.placement.value = advert.placement;
  els.campaignType.value = advert.campaign_type;
  els.discountPercent.value = advert.discount_percent ?? "";
  els.productId.value = advert.product_id ?? "";
  els.categoryId.value = advert.category_id ?? "";
  els.active.checked = Boolean(advert.active);
  els.priority.value = advert.priority;
  els.startsAt.value = toInputDateTime(advert.starts_at);
  els.endsAt.value = toInputDateTime(advert.ends_at);

  els.formTitle.textContent = "تعديل الإعلان";
  els.submitButton.textContent = "تحديث الإعلان";
  els.cancelEditButton.classList.remove("hidden");
  updatePreview();
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function resetForm() {
  els.form.reset();
  els.advertId.value = "";
  els.placement.value = "home_hero";
  els.campaignType.value = "offer";
  els.priority.value = "10";
  els.active.checked = true;
  setDefaultDates();
  els.formTitle.textContent = "إعلان جديد";
  els.submitButton.textContent = "حفظ الإعلان";
  els.cancelEditButton.classList.add("hidden");
  updatePreview();
}

function userFromForm() {
  return {
    name: els.userName.value.trim(),
    email: emptyToNull(els.userEmail.value),
    phone: emptyToNull(els.userPhone.value),
    is_active: els.userActive.checked,
    is_verified: els.userVerified.checked,
  };
}

function editUser(id) {
  const user = state.users.find((item) => item.id === id);
  if (!user) return;

  els.userId.value = user.id;
  els.userName.value = user.name || "";
  els.userEmail.value = user.email || "";
  els.userPhone.value = user.phone || "";
  els.userActive.checked = Boolean(user.is_active);
  els.userVerified.checked = Boolean(user.is_verified);
  els.userForm.classList.remove("hidden");
  els.userName.focus();
}

function resetUserForm() {
  els.userForm.reset();
  els.userId.value = "";
  els.userForm.classList.add("hidden");
}

function render() {
  const filtered = state.selectedPlacement
    ? state.adverts.filter((advert) => advert.placement === state.selectedPlacement)
    : state.adverts;

  els.totalCount.textContent = String(state.adverts.length);
  els.activeCount.textContent = String(
    state.adverts.filter((advert) => advert.active).length,
  );
  els.offerCount.textContent = String(
    state.adverts.filter((advert) => advert.campaign_type === "offer").length,
  );

  if (filtered.length === 0) {
    els.advertsList.innerHTML = `<p class="status">لا توجد إعلانات مطابقة</p>`;
    return;
  }

  els.advertsList.innerHTML = filtered.map(advertCard).join("");
  document.querySelectorAll("[data-edit]").forEach((button) => {
    button.addEventListener("click", () => editAdvert(Number(button.dataset.edit)));
  });
  document.querySelectorAll("[data-toggle]").forEach((button) => {
    button.addEventListener("click", () =>
      toggleAdvert(Number(button.dataset.toggle)),
    );
  });
  document.querySelectorAll("[data-delete]").forEach((button) => {
    button.addEventListener("click", () =>
      deleteAdvert(Number(button.dataset.delete)),
    );
  });
}

function renderUsers() {
  const users = state.userSearch
    ? state.users.filter((user) => {
        const haystack = `${user.name || ""} ${user.email || ""} ${user.phone || ""}`.toLowerCase();
        return haystack.includes(state.userSearch);
      })
    : state.users;

  els.usersCount.textContent = String(state.users.length);
  els.activeUsersCount.textContent = String(
    state.users.filter((user) => user.is_active).length,
  );
  els.verifiedUsersCount.textContent = String(
    state.users.filter((user) => user.is_verified).length,
  );

  if (users.length === 0) {
    els.usersList.innerHTML = `<p class="status">لا يوجد مستخدمون مطابقون</p>`;
    return;
  }

  els.usersList.innerHTML = users.map(userCard).join("");
  document.querySelectorAll("[data-user-edit]").forEach((button) => {
    button.addEventListener("click", () =>
      editUser(Number(button.dataset.userEdit)),
    );
  });
  document.querySelectorAll("[data-user-active]").forEach((button) => {
    button.addEventListener("click", () =>
      toggleUser(Number(button.dataset.userActive), "is_active"),
    );
  });
  document.querySelectorAll("[data-user-verified]").forEach((button) => {
    button.addEventListener("click", () =>
      toggleUser(Number(button.dataset.userVerified), "is_verified"),
    );
  });
  document.querySelectorAll("[data-user-delete]").forEach((button) => {
    button.addEventListener("click", () =>
      deleteUser(Number(button.dataset.userDelete)),
    );
  });
}

function advertCard(advert) {
  const statusClass = advert.active ? "active" : "inactive";
  const statusLabel = advert.active ? "نشط" : "متوقف";
  const discount =
    advert.discount_percent !== null ? `<span class="badge">${advert.discount_percent}%</span>` : "";
  return `
    <article class="advert-card">
      <img src="${escapeAttr(advert.image_url)}" alt="" loading="lazy" />
      <div class="advert-body">
        <div class="advert-title-row">
          <h3>${escapeHtml(advert.title_ar)}</h3>
          <span class="badge ${statusClass}">${statusLabel}</span>
        </div>
        <p>${escapeHtml(advert.subtitle_ar)}</p>
        <div class="meta">
          <span class="badge">${placementLabel(advert.placement)}</span>
          <span class="badge">${escapeHtml(advert.campaign_type)}</span>
          ${discount}
          <span class="badge">أولوية ${advert.priority}</span>
        </div>
        <div class="card-actions">
          <button type="button" data-edit="${advert.id}">تعديل</button>
          <button class="ghost" type="button" data-toggle="${advert.id}">
            ${advert.active ? "تعطيل" : "تفعيل"}
          </button>
          <button class="danger" type="button" data-delete="${advert.id}">حذف</button>
        </div>
      </div>
    </article>
  `;
}

function userCard(user) {
  const activeClass = user.is_active ? "active" : "inactive";
  const activeLabel = user.is_active ? "نشط" : "متوقف";
  const verifiedClass = user.is_verified ? "active" : "inactive";
  const verifiedLabel = user.is_verified ? "موثق" : "غير موثق";
  const createdAt = user.created_at
    ? new Date(user.created_at).toLocaleDateString("ar")
    : "";

  return `
    <article class="user-card">
      <div>
        <h3>${escapeHtml(user.name || "مستخدم بدون اسم")}</h3>
        <p>${escapeHtml(user.email || "بدون بريد")} · ${escapeHtml(user.phone || "بدون هاتف")}</p>
        <div class="meta">
          <span class="badge ${activeClass}">${activeLabel}</span>
          <span class="badge ${verifiedClass}">${verifiedLabel}</span>
          <span class="badge">#${user.id}</span>
          ${createdAt ? `<span class="badge">${createdAt}</span>` : ""}
        </div>
      </div>
      <div class="card-actions">
        <button type="button" data-user-edit="${user.id}">تعديل</button>
        <button class="ghost" type="button" data-user-active="${user.id}">
          ${user.is_active ? "تعطيل" : "تفعيل"}
        </button>
        <button class="ghost" type="button" data-user-verified="${user.id}">
          ${user.is_verified ? "إلغاء التوثيق" : "توثيق"}
        </button>
        <button class="danger" type="button" data-user-delete="${user.id}">حذف</button>
      </div>
    </article>
  `;
}

function updatePreview() {
  els.imagePreview.src = els.imageUrl.value.trim();
  els.previewTitle.textContent = els.titleAr.value.trim() || "معاينة الإعلان";
  const discount = els.discountPercent.value
    ? `، خصم ${els.discountPercent.value}%`
    : "";
  els.previewMeta.textContent = `${placementLabel(els.placement.value)}، ${els.campaignType.value}${discount}`;
}

function setDefaultDates() {
  const now = new Date();
  const end = new Date(now);
  end.setDate(end.getDate() + 30);
  els.startsAt.value = toInputDateTime(now.toISOString());
  els.endsAt.value = toInputDateTime(end.toISOString());
}

function emptyToNull(value) {
  const trimmed = value.trim();
  return trimmed === "" ? null : trimmed;
}

function toIso(value) {
  return new Date(value).toISOString();
}

function toInputDateTime(value) {
  const date = new Date(value);
  const local = new Date(date.getTime() - date.getTimezoneOffset() * 60000);
  return local.toISOString().slice(0, 16);
}

function placementLabel(value) {
  return (
    {
      home_hero: "واجهة الرئيسية",
      home_strip: "شريط الرئيسية",
      category: "التصنيفات",
    }[value] || value
  );
}

function setStatus(value) {
  els.statusText.textContent = value;
}

function showToast(message) {
  els.toast.textContent = message;
  els.toast.classList.add("show");
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => {
    els.toast.classList.remove("show");
  }, 2600);
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function escapeAttr(value) {
  return escapeHtml(value).replaceAll("`", "&#096;");
}

init();
