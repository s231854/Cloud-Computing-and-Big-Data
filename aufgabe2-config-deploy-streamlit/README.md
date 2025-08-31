# Aufgabe 2 – Configuration Management & Deployment (aufbauend auf Aufgabe 1)

Diese Lösung erweitert deine bestehende **Immutable Infrastructure** aus Aufgabe 1 um eine
**versionierbare Anwendung**, die direkt **über die Infrastrukturdefinition** (cloud-init) installiert,
gestartet und verifiziert wird. Zusätzlich zeigen wir, wie **Rollout/Rollback** funktioniert und wie alte
Versionen **entfernt** werden können.

## Architekturüberblick
- **OpenStack + Terraform** erstellt eine VM pro Version (`app-<version>`).
- **cloud-init** installiert Python + Streamlit und hinterlegt die Anwendungsversion.
- **Systemd** startet die App als Dienst auf Port `8080`.
- **Ansible (optional)** verifiziert Lauf- und Antwortfähigkeit inkl. Versionsprüfung.

## Versionierung
- **Anwendung:** Quellcode liegt im Repo unter `app/vX.Y.Z/app.py`. Die gewählte Version wird mit
  `var.app_version` in die VM gerendert (immutable Rollout).
- **Infrastruktur:** Das Terraform-Modul ist selbst versioniert (Git Tags/Branches). Ein Checkout eines
  älteren Tags + `-var app_version=...` installiert exakt diese Version erneut.

## Quickstart

> Voraussetzung: Du hast **dieselben `terraform.tfvars`** (OpenStack-Creds) wie in Aufgabe 1.

```bash
cd terraform
terraform init
terraform plan -var-file=../terraform.tfvars

# v1.0.0 ausrollen (Default)
terraform apply -var-file=../terraform.tfvars -auto-approve
# Ausgabe zeigt 'app_url'. Öffne diese URL.

# Auf v1.1.0 aktualisieren (immutable: neue VM, FIP wechselt automatisch)
terraform apply -var-file=../terraform.tfvars -var app_version=v1.1.0 -auto-approve
```

### Verifikation mit Ansible (optional)
```bash
cd ansible
# inventory/inventory.ini wurde von Terraform erzeugt
ansible -i inventory/inventory.ini all -m ping
ansible-playbook -i inventory/inventory.ini verify.yml -e expected_version=v1.1.0
```

## Rollback & Aufräumen

**Rollback:** Einfach die frühere Version erneut anwenden:
```bash
terraform apply -var-file=../terraform.tfvars -var app_version=v1.0.0 -auto-approve
```

**Alte Version entfernen:** Da `create_before_destroy` aktiv ist, existieren Versionen kurzzeitig parallel.
Nach erfolgreichem Wechsel sorgt Terraform automatisch für das **Destroy** der alten VM. Zusätzlich kannst du
am Ende alle Ressourcen entfernen:
```bash
terraform destroy -var-file=../terraform.tfvars -auto-approve
```

## Dateien

- `terraform/main.src.tf` – HCL mit Cloud-Init-Template (per `preprocess.py` nach `main.tf` rendern)
- `terraform/preprocess.py` – ersetzt `indent(file(...), N)` Stellen
- `ansible/verify.yml` – prüft Service-Status und ob die ausgelieferte Version stimmt
- `app/v1.0.0/`, `app/v1.1.0/` – Beispielanwendung in zwei Versionen
- `scripts/release.sh` – Komfort-Skript für Rollouts (Tags/Branches optional)

## Bonus-Ideen (optional)
- **Blue/Green**: zwei VMs + Floating-IP-Switch zum nahezu downtime-freien Wechsel
- **Image-Build** via Packer: App vorinstallieren und per Terraform nur Images rotieren
- **CI/CD**: Git-Tag `vX.Y.Z` triggert Terraform-Plan/Apply

---

**Hinweis:** Diese Abgabe trennt klar Aufgabe 1 und Aufgabe 2 in separaten Ordnern und dokumentiert alle
Schritte. Die Anforderungen aus der Aufgabenstellung (Installation über Infrastrukturdefinition, Versionierung,
Rollback und Entfernen alter Versionen) sind damit abgedeckt.
