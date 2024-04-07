
# Reconbuster

Mass hunting Recon Scripts




## Run Locally

Script to search for hidden directorty

```bash
  bash hidden-dir.sh domains_list.txt
```

Script to omit WAF enabled subdomains and then run Nuclei

```bash
  export domain=example.com
  wafnuclei.sh
```

Fuzzing on multiple URLs from multiple subdomains and domains

```bash
  dast.sh (paste the domains.txt in the same directorty)
```



