from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import html
import json
import posixpath
import re
import shutil
import subprocess
import sys
import unicodedata
import zipfile
from dataclasses import dataclass, field
from pathlib import Path
from xml.etree import ElementTree as ET

from bs4 import BeautifulSoup, NavigableString
from markdownify import markdownify
from pypdf import PdfReader


ROOT = Path(r"C:\Users\jungg\Desktop\CONSOLE\50_library\study\textbooks")
SOURCE_ROOT = ROOT / "10_sources" / "springer"
SOURCE_TEXT_ROOT = ROOT / "15_source_text" / "springer"
CONVERTED_ROOT = ROOT / "20_converted_md" / "springer"
INDEX_ROOT = ROOT / "40_indexes"

TODAY = dt.date.today().isoformat()

PDF_OVERRIDES = {
    "978-3-031-73974-3.pdf": {
        "title": "Understanding Natural Language Understanding",
        "authors": ["Erik Cambria"],
    },
    "978-3-031-65647-7.pdf": {
        "title": "Large Language Models: A Deep Dive",
        "authors": ["Uday Kamath", "Kevin Keenan", "Garrett Somers", "Sarah Sorenson"],
    },
    "978-3-031-02177-0.pdf": {
        "title": "Embeddings in Natural Language Processing",
        "authors": ["Mohammad Taher Pilehvar", "Jose Camacho-Collados"],
    },
}

TOPIC_MAP = {
    "Natural language processing": [
        "Natural Language Processing",
        "Large Language Models",
        "Representation Learning for Natural Language Processing",
        "Embeddings in Natural Language Processing",
        "Understanding Natural Language Understanding",
    ],
    "Large language models": [
        "Large Language Models",
        "Large Language Models: A Deep Dive",
        "Introduction to Python and Large Language Models",
    ],
    "Embeddings and vector representations": [
        "Embeddings in Natural Language Processing",
        "Representation Learning for Natural Language Processing",
        "Natural Language Processing",
    ],
    "Natural language understanding": [
        "Understanding Natural Language Understanding",
        "Natural Language Processing",
        "Large Language Models",
    ],
    "Affective computing and emotion": [
        "Textual Emotion Classification Using Deep Broad Learning",
        "Affective Computing for Social Good",
        "Computer Analysis of Human Behavior",
    ],
    "Human behavior and social good": [
        "Computer Analysis of Human Behavior",
        "Affective Computing for Social Good",
    ],
    "Python and LLM programming": [
        "Introduction to Python and Large Language Models",
    ],
    "Representation learning": [
        "Representation Learning for Natural Language Processing",
        "Embeddings in Natural Language Processing",
        "Large Language Models",
    ],
}

NS = {
    "container": "urn:oasis:names:tc:opendocument:xmlns:container",
    "opf": "http://www.idpf.org/2007/opf",
    "dc": "http://purl.org/dc/elements/1.1/",
}


@dataclass
class Book:
    source_path: Path
    source_copy: Path
    ext: str
    title: str
    authors: list[str]
    identifiers: list[str] = field(default_factory=list)
    subjects: list[str] = field(default_factory=list)
    language: str = ""
    publisher: str = ""
    date: str = ""
    page_count: int = 0
    spine_count: int = 0
    sha256: str = ""
    slug: str = ""
    source_text_path: Path | None = None
    converted_path: Path | None = None
    unreadable_count: int = 0
    extracted_markers: int = 0
    converted_markers: int = 0


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def write_utf8_bom(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.replace("\r\n", "\n"), encoding="utf-8-sig", newline="\n")


def read_xml_text(el: ET.Element | None) -> str:
    if el is None:
        return ""
    return "".join(el.itertext()).strip()


def norm_ascii(value: str) -> str:
    value = unicodedata.normalize("NFKD", value)
    value = value.encode("ascii", "ignore").decode("ascii")
    return value


def last_name(name: str) -> str:
    name = re.sub(r"[^A-Za-z0-9 \-]", "", norm_ascii(name)).strip()
    if not name:
        return "Unknown"
    return re.split(r"\s+", name)[-1]


def slug_for(title: str, authors: list[str], source_name: str) -> str:
    if not authors:
        author_part = "Unknown"
    elif len(authors) == 1:
        author_part = last_name(authors[0])
    elif len(authors) <= 3:
        author_part = "".join(last_name(a) for a in authors)
    else:
        author_part = f"{last_name(authors[0])}EtAl"

    title_part = re.sub(r"[^A-Za-z0-9]+", "", norm_ascii(title))
    if len(title_part) > 56:
        title_part = title_part[:56]
    isbn = Path(source_name).stem
    return f"{author_part}_{title_part}_{isbn}"


def metadata_epub(path: Path, source_copy: Path, sha: str) -> Book:
    with zipfile.ZipFile(source_copy) as z:
        container = ET.fromstring(z.read("META-INF/container.xml"))
        rootfile = container.find(".//container:rootfile", NS).attrib["full-path"]
        opf = ET.fromstring(z.read(rootfile))
        md = opf.find("opf:metadata", NS)
        title = ""
        authors: list[str] = []
        identifiers: list[str] = []
        subjects: list[str] = []
        language = ""
        publisher = ""
        date = ""
        if md is not None:
            titles = [read_xml_text(e) for e in md.findall("dc:title", NS)]
            authors = [read_xml_text(e) for e in md.findall("dc:creator", NS) if read_xml_text(e)]
            identifiers = [read_xml_text(e) for e in md.findall("dc:identifier", NS) if read_xml_text(e)]
            subjects = [read_xml_text(e) for e in md.findall("dc:subject", NS) if read_xml_text(e)]
            langs = [read_xml_text(e) for e in md.findall("dc:language", NS) if read_xml_text(e)]
            pubs = [read_xml_text(e) for e in md.findall("dc:publisher", NS) if read_xml_text(e)]
            dates = [read_xml_text(e) for e in md.findall("dc:date", NS) if read_xml_text(e)]
            title = titles[0] if titles else path.stem
            language = langs[0] if langs else ""
            publisher = pubs[0] if pubs else ""
            date = dates[0] if dates else ""
        manifest = {
            item.attrib.get("id"): item.attrib
            for item in opf.findall(".//opf:manifest/opf:item", NS)
        }
        spine = [item.attrib.get("idref") for item in opf.findall(".//opf:spine/opf:itemref", NS)]
        spine_count = 0
        for idref in spine:
            item = manifest.get(idref)
            if item and item.get("media-type") in ("application/xhtml+xml", "text/html"):
                spine_count += 1

    book = Book(path, source_copy, ".epub", title, authors, identifiers, subjects, language, publisher, date, 0, spine_count, sha)
    book.slug = slug_for(book.title, book.authors, source_copy.name)
    book.source_text_path = SOURCE_TEXT_ROOT / f"{book.slug}__source_text.md"
    return book


def metadata_pdf(path: Path, source_copy: Path, sha: str) -> Book:
    reader = PdfReader(str(source_copy))
    meta = reader.metadata or {}
    title = str(meta.get("/Title", "") or "").strip()
    author_raw = str(meta.get("/Author", "") or "").strip()
    authors = [author_raw] if author_raw else []
    if source_copy.name in PDF_OVERRIDES:
        override = PDF_OVERRIDES[source_copy.name]
        title = override["title"]
        authors = override["authors"]
    if not title:
        title = path.stem
    book = Book(path, source_copy, ".pdf", title, authors, page_count=len(reader.pages), sha256=sha)
    book.slug = slug_for(book.title, book.authors, source_copy.name)
    book.source_text_path = SOURCE_TEXT_ROOT / f"{book.slug}__source_text.md"
    book.converted_path = CONVERTED_ROOT / f"{book.slug}__readable.md"
    return book


def load_books(inputs: list[Path]) -> list[Book]:
    SOURCE_ROOT.mkdir(parents=True, exist_ok=True)
    SOURCE_TEXT_ROOT.mkdir(parents=True, exist_ok=True)
    CONVERTED_ROOT.mkdir(parents=True, exist_ok=True)
    INDEX_ROOT.mkdir(parents=True, exist_ok=True)

    books: list[Book] = []
    for src in inputs:
        if not src.exists():
            raise FileNotFoundError(src)
        dst = SOURCE_ROOT / src.name
        if dst.exists():
            if sha256_file(src) != sha256_file(dst):
                raise RuntimeError(f"Source copy exists with different hash: {dst}")
        else:
            shutil.copy2(src, dst)
        sha = sha256_file(src)
        if src.suffix.lower() == ".epub":
            books.append(metadata_epub(src, dst, sha))
        elif src.suffix.lower() == ".pdf":
            books.append(metadata_pdf(src, dst, sha))
        else:
            raise ValueError(f"Unsupported file type: {src}")
    return books


def opf_details(epub_path: Path) -> tuple[str, dict[str, dict[str, str]], list[str]]:
    with zipfile.ZipFile(epub_path) as z:
        container = ET.fromstring(z.read("META-INF/container.xml"))
        rootfile = container.find(".//container:rootfile", NS).attrib["full-path"]
        opf = ET.fromstring(z.read(rootfile))
        base = posixpath.dirname(rootfile)
        manifest = {
            item.attrib.get("id"): dict(item.attrib)
            for item in opf.findall(".//opf:manifest/opf:item", NS)
        }
        spine = [item.attrib.get("idref") for item in opf.findall(".//opf:spine/opf:itemref", NS)]
    return base, manifest, spine


def zip_join(base: str, href: str) -> str:
    if not base:
        return posixpath.normpath(href)
    return posixpath.normpath(posixpath.join(base, href))


def clean_markdown(text: str) -> str:
    text = html.unescape(text)
    text = text.replace("\u00a0", " ")
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{4,}", "\n\n\n", text)
    return text.strip()


def epub_html_to_md(z: zipfile.ZipFile, href: str) -> tuple[str, str, int]:
    raw = z.read(href)
    html_text = raw.decode("utf-8", errors="replace")
    soup = BeautifulSoup(html_text, "lxml")
    for tag in soup(["script", "style"]):
        tag.decompose()

    for tag in soup.find_all(True):
        values = " ".join(
            str(tag.get(attr, "")) for attr in ("epub:type", "role", "class", "type", "aria-label")
        ).lower()
        if "pagebreak" in values or "doc-pagebreak" in values:
            label = tag.get_text(" ", strip=True) or tag.get("title") or tag.get("id") or tag.get("aria-label") or ""
            tag.replace_with(NavigableString(f"\n\n[pagebreak: {label or 'unlabeled'}]\n\n"))

    for math_tag in soup.find_all("math"):
        math_tag.replace_with(NavigableString(f"\n\n[mathml]\n{str(math_tag)}\n[/mathml]\n\n"))

    for img in soup.find_all("img"):
        src = img.get("src", "").strip()
        alt = img.get("alt", "").strip()
        img.replace_with(NavigableString(f'[figure/image: src="{src}" alt="{alt}"]'))

    title = ""
    heading = soup.find(re.compile(r"^h[1-6]$"))
    if heading:
        title = heading.get_text(" ", strip=True)
    body = soup.body or soup
    md = markdownify(str(body), heading_style="ATX", bullets="-")
    md = clean_markdown(md)
    unreadable = 0 if md.strip() else 1
    if unreadable:
        md = "[unreadable: no extractable text from this EPUB spine item]"
    return md, title, unreadable


def extract_epub(book: Book) -> None:
    base, manifest, spine = opf_details(book.source_copy)
    lines = front_matter(book, "EPUB XHTML spine extraction")
    spine_no = 0
    unreadable = 0
    with zipfile.ZipFile(book.source_copy) as z:
        for idref in spine:
            item = manifest.get(idref)
            if not item or item.get("media-type") not in ("application/xhtml+xml", "text/html"):
                continue
            href = zip_join(base, item.get("href", ""))
            spine_no += 1
            md, heading, unreadable_item = epub_html_to_md(z, href)
            unreadable += unreadable_item
            label = heading or Path(href).stem
            lines.append(f"\n\n<!-- epub-spine: {spine_no:03d}; href: {href} -->")
            lines.append(f"\n## [EPUB spine {spine_no:03d}] {label}\n")
            lines.append(md)

    book.unreadable_count = unreadable
    book.extracted_markers = spine_no
    write_utf8_bom(book.source_text_path, "\n".join(lines) + "\n")


def pdftotext_layout(path: Path) -> str:
    cmd = ["pdftotext", "-enc", "UTF-8", "-layout", "-eol", "unix", str(path), "-"]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    return result.stdout.decode("utf-8", errors="replace")


def extract_pdf_pages(book: Book) -> list[str]:
    text = pdftotext_layout(book.source_copy)
    pages = text.split("\f")
    if pages and not pages[-1].strip():
        pages = pages[:-1]
    if len(pages) < book.page_count:
        pages.extend([""] * (book.page_count - len(pages)))
    return pages[: book.page_count]


def front_matter(book: Book, method: str) -> list[str]:
    authors = "; ".join(book.authors) if book.authors else "Unknown"
    identifiers = "; ".join(book.identifiers) if book.identifiers else Path(book.source_copy.name).stem
    return [
        f"# {book.title}",
        "",
        "## Extraction Metadata",
        "",
        f"- Authors/editors: {authors}",
        f"- Original file name: {book.source_copy.name}",
        f"- Source copy path: {book.source_copy}",
        f"- Source SHA-256: {book.sha256}",
        f"- Identifiers: {identifiers}",
        f"- Extraction date: {TODAY}",
        f"- Extraction method: {method}",
        "- Preservation note: This file is extracted original text, not a summary, translation, paraphrase, or concept note.",
    ]


def extract_pdf(book: Book) -> list[str]:
    pages = extract_pdf_pages(book)
    lines = front_matter(book, "Poppler pdftotext -layout, UTF-8")
    unreadable = 0
    for i, page in enumerate(pages, 1):
        text = page.replace("\x00", "").rstrip()
        if not text.strip():
            text = "[unreadable: no extractable text on this page]"
            unreadable += 1
        lines.append(f"\n\n<!-- pdf-page: {i} -->")
        lines.append(f"\n## [PDF page {i}]\n")
        lines.append(text)
    book.unreadable_count = unreadable
    book.extracted_markers = len(pages)
    write_utf8_bom(book.source_text_path, "\n".join(lines) + "\n")
    return pages


def readable_pdf_md(book: Book, pages: list[str]) -> None:
    lines = front_matter(book, "Readable Markdown derived after source text preservation")
    lines.append("- Conversion note: Page order and page markers are retained. Layout whitespace is lightly cleaned for reading; no summarization is performed.")
    for i, page in enumerate(pages, 1):
        text = page.replace("\x00", "").rstrip()
        if not text.strip():
            text = "[unreadable: no extractable text on this page]"
        text = re.sub(r"[ \t]+\n", "\n", text)
        text = re.sub(r"\n{4,}", "\n\n\n", text)
        lines.append(f"\n\n<!-- pdf-page: {i} -->")
        lines.append(f"\n## Page {i}\n")
        lines.append(text)
    book.converted_markers = len(pages)
    write_utf8_bom(book.converted_path, "\n".join(lines) + "\n")


def extract_all(books: list[Book]) -> None:
    for book in books:
        if book.ext == ".epub":
            extract_epub(book)
        else:
            extract_pdf(book)


def convert_pdfs(books: list[Book]) -> None:
    for book in books:
        if book.ext != ".pdf":
            continue
        pages = extract_pdf_pages(book)
        readable_pdf_md(book, pages)


def verify_books(books: list[Book]) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for book in books:
        source_ok = book.source_copy.exists() and sha256_file(book.source_path) == sha256_file(book.source_copy)
        text = book.source_text_path.read_text(encoding="utf-8-sig") if book.source_text_path and book.source_text_path.exists() else ""
        if book.ext == ".pdf":
            marker_count = len(re.findall(r"<!-- pdf-page: \d+ -->", text))
            expected = book.page_count
        else:
            marker_count = len(re.findall(r"<!-- epub-spine: \d+;", text))
            expected = book.spine_count
        unreadable_count = text.count("[unreadable:")
        source_text_ok = bool(text) and marker_count == expected and book.source_copy.name in text and book.title in text
        converted_ok = None
        converted_markers = 0
        if book.ext == ".pdf":
            converted = book.converted_path.read_text(encoding="utf-8-sig") if book.converted_path and book.converted_path.exists() else ""
            converted_markers = len(re.findall(r"<!-- pdf-page: \d+ -->", converted))
            converted_ok = bool(converted) and converted_markers == book.page_count
        rows.append(
            {
                "file": book.source_copy.name,
                "title": book.title,
                "type": book.ext[1:].upper(),
                "source_copy": str(book.source_copy.relative_to(ROOT)),
                "source_copy_ok": source_ok,
                "source_text": str(book.source_text_path.relative_to(ROOT)),
                "source_text_bytes": book.source_text_path.stat().st_size if book.source_text_path and book.source_text_path.exists() else 0,
                "markers": marker_count,
                "expected_markers": expected,
                "unreadable_markers": unreadable_count,
                "source_text_ok": source_text_ok,
                "converted_md": str(book.converted_path.relative_to(ROOT)) if book.converted_path else "",
                "converted_ok": converted_ok,
                "converted_markers": converted_markers,
            }
        )
    return rows


def md_link(path: Path) -> str:
    return str(path.relative_to(ROOT)).replace("\\", "/")


def write_indexes(books: list[Book], verification: list[dict[str, object]]) -> None:
    catalog = [
        "# Textbook Catalog",
        "",
        f"Updated: {TODAY}",
        "",
        "| Title | Authors/editors | Source file | Type |",
        "|---|---|---|---|",
    ]
    for book in books:
        catalog.append(
            f"| {book.title} | {'; '.join(book.authors) or 'Unknown'} | `{md_link(book.source_copy)}` | {book.ext[1:].upper()} |"
        )
    write_utf8_bom(INDEX_ROOT / "TEXTBOOK_CATALOG.md", "\n".join(catalog) + "\n")

    source_map = [
        "# Source Map",
        "",
        f"Updated: {TODAY}",
        "",
        "| Title | Source text | Converted Markdown |",
        "|---|---|---|",
    ]
    for book in books:
        converted = f"`{md_link(book.converted_path)}`" if book.converted_path else "Not generated for EPUB yet"
        source_map.append(f"| {book.title} | `{md_link(book.source_text_path)}` | {converted} |")
    write_utf8_bom(INDEX_ROOT / "SOURCE_MAP.md", "\n".join(source_map) + "\n")

    topic_lines = [
        "# Topic Index",
        "",
        f"Updated: {TODAY}",
        "",
        "Use this as a routing index. Confirm details in `15_source_text/` before citing.",
        "",
    ]
    by_title = {book.title: book for book in books}
    for topic, titles in TOPIC_MAP.items():
        topic_lines.append(f"## {topic}")
        for title in titles:
            book = by_title.get(title)
            if book:
                topic_lines.append(f"- {book.title}: `{md_link(book.source_text_path)}`")
        topic_lines.append("")
    write_utf8_bom(INDEX_ROOT / "TOPIC_INDEX.md", "\n".join(topic_lines).rstrip() + "\n")

    report = [
        "# Ingest Verification",
        "",
        f"Date: {TODAY}",
        "",
        "PASS means the source copy hash matches the original, source text exists, and marker count matches expected pages or EPUB spine items. PDF converted Markdown is checked separately.",
        "",
        "| File | Source copy | Source text | Markers | Unreadable | PDF MD |",
        "|---|---:|---:|---:|---:|---:|",
    ]
    for row in verification:
        converted = "n/a" if row["converted_ok"] is None else ("PASS" if row["converted_ok"] else "FAIL")
        report.append(
            f"| `{row['file']}` | {'PASS' if row['source_copy_ok'] else 'FAIL'} | {'PASS' if row['source_text_ok'] else 'FAIL'} | {row['markers']}/{row['expected_markers']} | {row['unreadable_markers']} | {converted} |"
        )
    write_utf8_bom(INDEX_ROOT / f"INGEST_VERIFICATION__{TODAY}.md", "\n".join(report) + "\n")

    manifest = {
        "updated": TODAY,
        "root": str(ROOT),
        "books": verification,
    }
    (INDEX_ROOT / "textbook_manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("inputs", nargs="+", type=Path)
    parser.add_argument("--phase", choices=["extract", "convert-index", "verify", "all"], default="all")
    args = parser.parse_args()

    books = load_books(args.inputs)
    if args.phase in ("extract", "all"):
        extract_all(books)
    if args.phase in ("convert-index", "all"):
        convert_pdfs(books)
        verification = verify_books(books)
        write_indexes(books, verification)
    if args.phase == "verify":
        verification = verify_books(books)
    elif args.phase == "extract":
        verification = verify_books(books)
    else:
        verification = verify_books(books)

    print(json.dumps(verification, ensure_ascii=False, indent=2))
    failed = [row for row in verification if not row["source_copy_ok"] or not row["source_text_ok"]]
    if args.phase in ("convert-index", "all"):
        failed.extend(row for row in verification if row["converted_ok"] is False)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
