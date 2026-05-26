# Deployments

Netlify 등 배포 대상, 배포 설정, 배포 로그, 사이트 사본을 두는 공간입니다.

## Rule

- 배포와 연결된 사이트는 이곳에 둡니다.
- 실험용 prototype은 먼저 `../10_projects/<project>/`에 둡니다.
- 배포가 비활성화되면 `../90_archive/`로 옮깁니다.
- 정적 prototype 공유는 Netlify production credits를 쓰기 전에 GitHub Pages를 우선 사용합니다.
- Root `.netlify/`는 Netlify CLI가 만드는 local state이고 `.gitignore`로 제외되며, 원격 배포 상태의 source of truth가 아닙니다.

## Current

- [GitHub Pages public prototype](https://hyun-ilab.github.io/CONSOLE/)
- [Netlify Console14 backend experiment](https://console-demo.netlify.app/10_projects/console14/prototype_backend_experiment.html)
- [netlify_console_demo](netlify_console_demo/index.html) remains the older static demo copy used by the site root redirect.
