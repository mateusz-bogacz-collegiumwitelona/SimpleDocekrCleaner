# Simple Docker Cleaner

Skrypt PowerShell do oczyszczania zasobów Dockera, zamykania instancji WSL i optymalizacji pliku VHDX używanego przez Docker Desktop na Windows.

---

## Funkcje

- Sprawdza, czy skrypt jest uruchomiony jako administrator.
- Czyści wszystkie kontenery, obrazy i wolumeny Dockera (`docker system prune -a --volumes -f`).
- Zatrzymuje usługę Docker Desktop.
- Kończy działanie dystrybucji WSL `docker-desktop` i `docker-desktop-data`.
- Wyłącza WSL.
- Optymalizuje plik `docker_data.vhdx`, a w razie problemów używa metody `diskpart`.
- Loguje wszystkie działania i błędy w pliku na pulpicie w folderze `DockerCleanerLogs`.

---

## Wymagania

- Windows 10/11
- PowerShell uruchomiony jako administrator
- Docker Desktop z włączonym WSL 2
- Moduł Hyper-V (dla `Optimize-VHD`)

---

## Instrukcja użycia

1. Pobierz skrypt `optimalization.ps1` na komputer.

2. Uruchom PowerShell **jako administrator**.
3. Przejdź do folderu ze skryptem:

```powershell
cd C:\ścieżka\do\skryptu
```

4. Uruchom skrypt:

```powershell
.\optimalization.ps1
```

5. Postępuj zgodnie z komunikatami na ekranie. Skrypt zatrzyma się w przypadku błędów i poczeka na naciśnięcie **Enter**.
6. Po zakończeniu działania logi zostaną zapisane w folderze `DockerCleanerLogs` na pulpicie.

---

## Uwagi

- Skrypt **usuwa wszystkie nieużywane kontenery, obrazy i wolumeny** Dockera – upewnij się, że nie potrzebujesz żadnych danych.
- Jeśli VHDX nie istnieje lub WSL nie działa, skrypt zgłosi błąd i zapisze go w logu.
- Logi zawierają timestamp oraz typ komunikatu (`INFO`, `WARNING`, `ERROR`).
- Logi są zapisywane na pulpicie w folderze `SimpleDockerCleanerLogs`
