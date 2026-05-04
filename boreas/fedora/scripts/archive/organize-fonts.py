#!/usr/bin/env python3

"""
Font organizer script for Fedora font guidelines
Organizes fonts into subdirectories by family name with normalized filenames
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Set

# Try to import fonttools
try:
    from fontTools.ttLib import TTFont
    from fontTools.ttLib.tables._n_a_m_e import NameRecord
    FONTTOOLS_AVAILABLE = True
except ImportError:
    FONTTOOLS_AVAILABLE = False

# ANSI color codes
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    MAGENTA = '\033[0;35m'
    NC = '\033[0m'  # No Color

def print_color(text: str, color: str = Colors.NC):
    """Print colored text"""
    print(f"{color}{text}{Colors.NC}")

def check_fc_query() -> bool:
    """Check if fc-query is available"""
    return shutil.which('fc-query') is not None

def get_variable_font_axes(font_path: Path) -> Set[str]:
    """
    Get the list of variable axes in a variable font
    Returns set of axis tags like {'wght', 'wdth', 'ital', 'slnt'}
    """
    if not FONTTOOLS_AVAILABLE:
        return set()

    try:
        font = TTFont(str(font_path))
        if 'fvar' in font:
            axes = {axis.axisTag for axis in font['fvar'].axes}
            font.close()
            return axes
        font.close()
    except Exception as e:
        if '--debug' in sys.argv:
            print_color(f"[DEBUG] Error reading axes from {font_path.name}: {e}", Colors.YELLOW)

    return set()

def is_variable_font(font_path: Path) -> bool:
    """
    Check if a font is a variable font
    Uses fonttools first, falls back to fc-query
    """
    # Try fonttools first (most accurate)
    if FONTTOOLS_AVAILABLE:
        try:
            font = TTFont(str(font_path))
            has_fvar = 'fvar' in font
            font.close()
            return has_fvar
        except Exception as e:
            if '--debug' in sys.argv:
                print_color(f"[DEBUG] fonttools error for {font_path.name}: {e}", Colors.YELLOW)

    # Fallback to fc-query
    if check_fc_query():
        try:
            result = subprocess.run(
                ['fc-query', '--format=%{variable}', str(font_path)],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                output = result.stdout.strip()
                return output.lower() == 'true'
        except (subprocess.TimeoutExpired, subprocess.SubprocessError):
            pass

    return False

def get_font_names_from_ttf(font_path: Path) -> Tuple[Optional[str], Optional[str]]:
    """
    Extract font family and subfamily (style) names from font using fonttools
    Returns: (family_name, style_name)
    """
    if not FONTTOOLS_AVAILABLE:
        return None, None

    try:
        font = TTFont(str(font_path))

        if 'name' not in font:
            font.close()
            return None, None

        name_table = font['name']

        # Name ID 1 = Font Family name
        # Name ID 2 = Font Subfamily name (style)
        # Name ID 16 = Typographic Family name (preferred)
        # Name ID 17 = Typographic Subfamily name (preferred)

        family_name = None
        style_name = None

        # Try to get preferred names first (ID 16, 17)
        for record in name_table.names:
            if record.nameID == 16 and record.platformID == 3:  # Windows platform
                family_name = record.toUnicode()
                break

        for record in name_table.names:
            if record.nameID == 17 and record.platformID == 3:
                style_name = record.toUnicode()
                break

        # Fallback to regular names (ID 1, 2)
        if not family_name:
            for record in name_table.names:
                if record.nameID == 1 and record.platformID == 3:
                    family_name = record.toUnicode()
                    break

        if not style_name:
            for record in name_table.names:
                if record.nameID == 2 and record.platformID == 3:
                    style_name = record.toUnicode()
                    break

        font.close()
        return family_name, style_name

    except Exception as e:
        if '--debug' in sys.argv:
            print_color(f"[DEBUG] Error reading font names from {font_path.name}: {e}", Colors.YELLOW)
        return None, None

def to_pascal_case(text: str) -> str:
    """
    Convert text to PascalCase
    Examples: "foo bar" -> "FooBar", "foo-bar" -> "FooBar"
    """
    # Split on spaces, dashes, underscores
    words = re.split(r'[\s\-_]+', text)
    # Capitalize each word
    pascal = ''.join(word.capitalize() for word in words if word)
    return pascal

def normalize_style_name(style: str) -> str:
    """
    Normalize style name to standard format
    Maps common variations (including international) to standard names in PascalCase
    """
    style_lower = style.lower().strip()

    # Common style mappings (including international variants)
    style_map = {
        # English - single styles
        'regular': 'Regular',
        'normal': 'Regular',
        'book': 'Regular',
        'roman': 'Regular',
        'bold': 'Bold',
        'italic': 'Italic',
        'oblique': 'Italic',

        # Catalan
        'negreta': 'Bold',
        'cursiva': 'Italic',
        'negreta cursiva': 'BoldItalic',

        # Spanish
        'negrita': 'Bold',
        'cursiva': 'Italic',
        'negrita cursiva': 'BoldItalic',

        # Portuguese
        'negrito': 'Bold',
        'itálico': 'Italic',
        'italico': 'Italic',
        'negrito itálico': 'BoldItalic',
        'negrito italico': 'BoldItalic',

        # French
        'gras': 'Bold',
        'italique': 'Italic',
        'gras italique': 'BoldItalic',
        'maigre': 'Light',
        'maigre italique': 'LightItalic',
        'moyen': 'Medium',
        'moyen italique': 'MediumItalic',
        'demi-gras': 'SemiBold',
        'demi gras': 'SemiBold',
        'demigras': 'SemiBold',
        'demi-gras italique': 'SemiBoldItalic',

        # Italian
        'grassetto': 'Bold',
        'neretto': 'Bold',
        'corsivo': 'Italic',
        'grassetto corsivo': 'BoldItalic',
        'neretto corsivo': 'BoldItalic',
        'chiaro': 'Light',
        'chiaro corsivo': 'LightItalic',
        'medio': 'Medium',
        'medio corsivo': 'MediumItalic',

        # German
        'fett': 'Bold',
        'kursiv': 'Italic',
        'fett kursiv': 'BoldItalic',
        'leicht': 'Light',
        'leicht kursiv': 'LightItalic',
        'halbfett': 'SemiBold',
        'halbfett kursiv': 'SemiBoldItalic',
        'mager': 'Thin',
        'mager kursiv': 'ThinItalic',

        # Dutch
        'vet': 'Bold',
        'cursief': 'Italic',
        'vet cursief': 'BoldItalic',
        'licht': 'Light',
        'licht cursief': 'LightItalic',
        'halfvet': 'SemiBold',
        'halfvet cursief': 'SemiBoldItalic',

        # Danish
        'fed': 'Bold',
        'kursiv': 'Italic',
        'fed kursiv': 'BoldItalic',
        'let': 'Light',
        'let kursiv': 'LightItalic',
        'halvfed': 'SemiBold',
        'halvfed kursiv': 'SemiBoldItalic',
        'tynd': 'Thin',
        'tynd kursiv': 'ThinItalic',
        'medium': 'Medium',
        'medium kursiv': 'MediumItalic',

        # Norwegian/Swedish
        'fet': 'Bold',
        'kursiv': 'Italic',
        'fet kursiv': 'BoldItalic',
        'lett': 'Light',
        'lett kursiv': 'LightItalic',
        'halvfet': 'SemiBold',
        'halvfet kursiv': 'SemiBoldItalic',
        'tynn': 'Thin',
        'tynn kursiv': 'ThinItalic',

        # Common weights (English)
        'light': 'Light',
        'medium': 'Medium',
        'thin': 'Thin',
        'extralight': 'ExtraLight',
        'extra-light': 'ExtraLight',
        'extra light': 'ExtraLight',
        'ultralight': 'ExtraLight',
        'black': 'Black',
        'heavy': 'Black',
        'semibold': 'SemiBold',
        'semi-bold': 'SemiBold',
        'semi bold': 'SemiBold',
        'demibold': 'SemiBold',
        'demi-bold': 'SemiBold',
        'demi bold': 'SemiBold',
        'extrabold': 'ExtraBold',
        'extra-bold': 'ExtraBold',
        'extra bold': 'ExtraBold',
        'ultrabold': 'ExtraBold',

        # Combined styles (English)
        'bolditalic': 'BoldItalic',
        'bold-italic': 'BoldItalic',
        'bold italic': 'BoldItalic',
        'boldoblique': 'BoldItalic',
        'bold oblique': 'BoldItalic',

        'lightitalic': 'LightItalic',
        'light-italic': 'LightItalic',
        'light italic': 'LightItalic',

        'mediumitalic': 'MediumItalic',
        'medium-italic': 'MediumItalic',
        'medium italic': 'MediumItalic',

        'thinitalic': 'ThinItalic',
        'thin-italic': 'ThinItalic',
        'thin italic': 'ThinItalic',

        'semibolditalic': 'SemiBoldItalic',
        'semibold-italic': 'SemiBoldItalic',
        'semibold italic': 'SemiBoldItalic',

        'blackitalic': 'BlackItalic',
        'black-italic': 'BlackItalic',
        'black italic': 'BlackItalic',

        'extralightitalic': 'ExtraLightItalic',
        'extralight-italic': 'ExtraLightItalic',
        'extralight italic': 'ExtraLightItalic',

        'extrabolditalic': 'ExtraBoldItalic',
        'extrabold-italic': 'ExtraBoldItalic',
        'extrabold italic': 'ExtraBoldItalic',

        # Width variants
        'condensed': 'Condensed',
        'expanded': 'Expanded',
        'narrow': 'Narrow',
        'wide': 'Wide',

        # Condensed combinations
        'bold condensed': 'BoldCondensed',
        'boldcondensed': 'BoldCondensed',
        'light condensed': 'LightCondensed',
        'lightcondensed': 'LightCondensed',
    }

    # Check if we have a direct mapping
    if style_lower in style_map:
        return style_map[style_lower]

    # Try removing spaces/dashes/underscores and checking again
    normalized = style_lower.replace(' ', '').replace('-', '').replace('_', '')
    if normalized in style_map:
        return style_map[normalized]

    # Try with spaces but no dashes (for compound names)
    normalized_spaces = style_lower.replace('-', ' ').replace('_', ' ')
    # Remove multiple spaces
    normalized_spaces = re.sub(r'\s+', ' ', normalized_spaces)
    if normalized_spaces in style_map:
        return style_map[normalized_spaces]

    # If no mapping found, convert to PascalCase
    return to_pascal_case(style)

def extract_style_from_filename(filename: str) -> Optional[str]:
    """Extract style from filename"""
    name = Path(filename).stem

    # Common style patterns
    style_patterns = [
        r'[-_\s](Regular|Bold|Italic|Light|Medium|Thin|Black|Heavy|Oblique|'
        r'BoldItalic|BoldOblique|LightItalic|MediumItalic|ThinItalic|SemiBold|ExtraBold|'
        r'DemiBold|Book|Condensed|Expanded|Narrow|Wide|Roman|ExtraLight|UltraLight)(?:[-_\s]|$)',
    ]

    for pattern in style_patterns:
        match = re.search(pattern, name, re.IGNORECASE)
        if match:
            return match.group(1)

    return None

def get_font_info(font_path: Path, use_fc_query: bool) -> Tuple[str, str]:
    """
    Get font family and style from font file
    Returns: (family_name, style_name)
    Priority: fonttools > fc-query > filename parsing
    """
    family_name = ""
    style_name = ""

    # Try fonttools first (most accurate)
    if FONTTOOLS_AVAILABLE:
        family_name, style_name = get_font_names_from_ttf(font_path)

    # Fallback to fc-query
    if (not family_name or not style_name) and use_fc_query:
        try:
            if not family_name:
                result = subprocess.run(
                    ['fc-query', '--format=%{family[0]}', str(font_path)],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                if result.returncode == 0:
                    family_name = result.stdout.strip().split('\n')[0]

            if not style_name:
                result = subprocess.run(
                    ['fc-query', '--format=%{style[0]}', str(font_path)],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                if result.returncode == 0:
                    style_name = result.stdout.strip().split('\n')[0]
        except (subprocess.TimeoutExpired, subprocess.SubprocessError):
            pass

    # Fallback to filename parsing
    if not family_name:
        basename = font_path.stem

        # Remove common font weight/style suffixes
        suffixes = [
            'Regular', 'Bold', 'Italic', 'Light', 'Medium', 'Thin',
            'Black', 'Heavy', 'Oblique', 'BoldItalic', 'BoldOblique',
            'LightItalic', 'MediumItalic', 'ThinItalic', 'SemiBold', 'ExtraBold',
            'DemiBold', 'Book', 'Condensed', 'Expanded', 'Narrow',
            'Wide', 'Roman', 'Mono', 'Nerd', 'NF', 'Complete',
            'WindowsCompatible', 'ExtraLight', 'UltraLight'
        ]

        pattern = r'[-_\s](' + '|'.join(suffixes) + r').*$'
        family_name = re.sub(pattern, '', basename, flags=re.IGNORECASE)

    if not style_name:
        style_name = extract_style_from_filename(font_path.name) or "Regular"

    # If still empty, use filename
    if not family_name:
        family_name = font_path.stem

    return family_name, style_name

def format_variable_axes(axes: Set[str]) -> str:
    """
    Format variable font axes for filename
    Returns string like [wght] or [wght,wdth] or [wght,ital]
    """
    if not axes:
        return "[wght]"  # Default fallback

    # Sort axes for consistent naming
    sorted_axes = sorted(axes)
    return f"[{','.join(sorted_axes)}]"

def normalize_filename(font_path: Path, use_fc_query: bool, debug: bool = False) -> str:
    """
    Normalize font filename according to the pattern:
    - Regular fonts: <FontName>-<Style>.<format>
    - Variable fonts: <FontName>[axes].<format>
    Both font name and style should be in PascalCase
    """
    family, style = get_font_info(font_path, use_fc_query)
    extension = font_path.suffix.lower()  # Normalize extension to lowercase

    # Convert family to PascalCase
    family_pascal = to_pascal_case(family)

    # Check if it's a variable font
    is_variable = is_variable_font(font_path)

    if is_variable:
        # Get variable axes
        axes = get_variable_font_axes(font_path)
        axes_str = format_variable_axes(axes)
        normalized = f"{family_pascal}{axes_str}{extension}"

        if debug:
            print_color(f"[DEBUG] {font_path.name} is variable with axes: {axes}", Colors.YELLOW)
    else:
        # Regular font: <FontName>-<Style>.<format>
        style_normalized = normalize_style_name(style)
        normalized = f"{family_pascal}-{style_normalized}{extension}"

        if debug:
            print_color(f"[DEBUG] {font_path.name}: family={family}, style={style} → {normalized}", Colors.YELLOW)

    return normalized

def normalize_dirname(name: str) -> str:
    """
    Normalize directory name: lowercase, spaces to dashes
    Remove special characters except alphanumeric and dashes
    """
    # Convert to lowercase
    name = name.lower()
    # Replace spaces with dashes
    name = re.sub(r'\s+', '-', name)
    # Remove non-alphanumeric characters except dashes
    name = re.sub(r'[^a-z0-9-]', '', name)
    # Remove multiple consecutive dashes
    name = re.sub(r'-+', '-', name)
    # Remove leading/trailing dashes
    name = name.strip('-')

    return name if name else "unknown-fonts"

def find_font_files(directory: Path) -> List[Path]:
    """Find all font files in the root of the directory"""
    font_extensions = ['.ttf', '.otf', '.woff', '.woff2', '.pfb', '.pfa', '.pcf', '.bdf']

    font_files = []
    for item in directory.iterdir():
        if item.is_file():
            if item.suffix.lower() in font_extensions:
                font_files.append(item)

    return sorted(font_files)

def group_fonts(font_files: List[Path], use_fc_query: bool, debug: bool = False) -> Tuple[Dict[str, List[Path]], Dict[str, str]]:
    """
    Group fonts by family name
    Returns: (font_groups, family_names) where font_groups maps normalized names to file lists
    and family_names maps normalized names to original family names
    """
    font_groups = defaultdict(list)
    family_names = {}

    for font_file in font_files:
        family, _ = get_font_info(font_file, use_fc_query)
        normalized = normalize_dirname(family)

        if normalized not in family_names:
            family_names[normalized] = family

        font_groups[normalized].append(font_file)

    if debug:
        print_color(f"\n[DEBUG] First 5 font files:", Colors.YELLOW)
        for f in font_files[:5]:
            family, style = get_font_info(f, use_fc_query)
            print(f"  {f.name} → family='{family}', style='{style}'")

    return dict(font_groups), family_names

def prompt_user(prompt_text: str) -> str:
    """Prompt user for input with colored text"""
    try:
        return input(f"{Colors.YELLOW}{prompt_text}{Colors.NC}")
    except (KeyboardInterrupt, EOFError):
        print_color("\n\nInterrupted by user", Colors.RED)
        sys.exit(0)

def organize_fonts(font_dir: Path, output_dir: Path, dry_run: bool = False, debug: bool = False):
    """Main function to organize fonts"""

    # Header
    print_color("=== Font Directory Organizer ===", Colors.BLUE)
    if dry_run:
        print_color("*** DRY-RUN MODE - No files will be copied ***", Colors.MAGENTA)
    print(f"Source directory:      {Colors.CYAN}{font_dir}{Colors.NC}")
    print(f"Destination directory: {Colors.CYAN}{output_dir}{Colors.NC}")

    # Show capabilities
    if FONTTOOLS_AVAILABLE:
        print_color("✓ fonttools available - enhanced font detection enabled", Colors.GREEN)
    else:
        print_color("✗ fonttools not available - using fallback methods", Colors.YELLOW)

    print()

    # Check if output directory exists
    if output_dir.exists() and not dry_run:
        print_color(f"Warning: Output directory already exists: {output_dir}", Colors.YELLOW)
        response = prompt_user("Overwrite/merge? [y/N]: ")
        if response.lower() not in ['y', 'yes']:
            print_color("Aborted.", Colors.RED)
            sys.exit(1)
        print()

    # Check for fc-query
    use_fc_query = check_fc_query()
    if not use_fc_query and not FONTTOOLS_AVAILABLE:
        print_color("Warning: Neither fc-query nor fonttools available.", Colors.YELLOW)
        print_color("Font detection will use filename parsing only.\n", Colors.YELLOW)

    # Find font files
    print_color("Scanning for font files in root directory...\n", Colors.BLUE)
    font_files = find_font_files(font_dir)

    if not font_files:
        print_color(f"No font files found in {font_dir}", Colors.YELLOW)
        sys.exit(0)

    print_color(f"Found {len(font_files)} font file(s) to organize", Colors.BLUE)
    print()

    # Group fonts by family
    print_color("Grouping fonts by family...", Colors.BLUE)
    font_groups, family_names = group_fonts(font_files, use_fc_query, debug)

    if not font_groups:
        print_color("Error: No font groups were created!", Colors.RED)
        print_color("This might indicate an issue with font family detection.", Colors.YELLOW)
        sys.exit(1)

    print_color(f"Created {len(font_groups)} font group(s)\n", Colors.GREEN)

    if debug:
        print_color(f"[DEBUG] Font groups created:", Colors.YELLOW)
        for name, files in sorted(font_groups.items())[:5]:
            print(f"  - {name}: {len(files)} file(s)")
        print()

    # Create output directory
    if not dry_run:
        output_dir.mkdir(parents=True, exist_ok=True)

    print_color("Starting interactive organization...\n", Colors.BLUE)

    # Process each group
    copied_count = 0
    sorted_groups = sorted(font_groups.keys())

    for group_num, normalized_dir in enumerate(sorted_groups, 1):
        files = font_groups[normalized_dir]
        original_family = family_names[normalized_dir]

        # Display group info
        print_color("━" * 70, Colors.CYAN)
        print_color(f"Group {group_num} of {len(sorted_groups)}", Colors.BLUE)
        print(f"{Colors.GREEN}Font Family:{Colors.NC} {original_family}")
        print(f"{Colors.GREEN}Target Directory:{Colors.NC} {normalized_dir}/")
        print(f"{Colors.GREEN}Files to organize ({len(files)}):{Colors.NC}")

        # Show original and normalized filenames
        file_mappings = []
        for f in files:
            normalized_name = normalize_filename(f, use_fc_query, debug)
            is_var = is_variable_font(f)

            if is_var:
                axes = get_variable_font_axes(f)
                axes_str = ', '.join(sorted(axes)) if axes else 'unknown'
                var_indicator = f" {Colors.MAGENTA}[VARIABLE: {axes_str}]{Colors.NC}"
            else:
                var_indicator = ""

            file_mappings.append((f, normalized_name))
            print(f"  • {f.name}{var_indicator}")
            print(f"    {Colors.CYAN}→{Colors.NC} {normalized_name}")

        print()

        # Prompt user for directory
        while True:
            response = prompt_user("[y]es / [n]o / [r]ename directory / [q]uit: ").lower()

            if response in ['q', 'quit']:
                print_color("Quitting...", Colors.RED)
                if copied_count > 0:
                    print_color(f"\nPartial organization completed. {copied_count} file(s) copied.", Colors.YELLOW)
                sys.exit(0)

            elif response in ['n', 'no']:
                print_color("Skipped.\n", Colors.YELLOW)
                break

            elif response in ['r', 'rename']:
                new_name = prompt_user("Enter new directory name (lowercase, dashes for spaces): ")
                if new_name.strip():
                    normalized_dir = new_name.strip()
                    print_color(f"✓ Will use directory name: {normalized_dir}", Colors.GREEN)
                else:
                    print_color("Invalid name, keeping original.", Colors.RED)
                continue

            elif response in ['y', 'yes']:
                target_dir = output_dir / normalized_dir

                # Allow user to override individual filenames
                final_mappings = []
                print_color("\nReview/edit filenames (press Enter to accept, or type new name):", Colors.CYAN)
                for orig_file, norm_name in file_mappings:
                    override = prompt_user(f"  {norm_name}: ")
                    if override.strip():
                        # User provided override
                        final_name = override.strip()
                        # Ensure it has the correct extension
                        if not final_name.endswith(orig_file.suffix.lower()):
                            final_name += orig_file.suffix.lower()
                        final_mappings.append((orig_file, final_name))
                        print_color(f"    → Using: {final_name}", Colors.GREEN)
                    else:
                        # Use normalized name
                        final_mappings.append((orig_file, norm_name))

                print()

                if dry_run:
                    # Dry-run mode
                    print(f"{Colors.MAGENTA}[DRY-RUN]{Colors.NC} Would create directory: {Colors.GREEN}{target_dir}{Colors.NC}")
                    for orig_file, final_name in final_mappings:
                        print(f"{Colors.MAGENTA}[DRY-RUN]{Colors.NC} Would copy: {orig_file.name} → {normalized_dir}/{final_name}")
                        copied_count += 1
                else:
                    # Actually copy files
                    target_dir.mkdir(parents=True, exist_ok=True)
                    print_color(f"✓ Created directory: {target_dir}", Colors.GREEN)

                    for orig_file, final_name in final_mappings:
                        try:
                            dest_path = target_dir / final_name
                            shutil.copy2(orig_file, dest_path)
                            print_color(f"✓ Copied: {orig_file.name} → {final_name}", Colors.GREEN)
                            copied_count += 1
                        except Exception as e:
                            print_color(f"✗ Failed to copy {orig_file.name}: {e}", Colors.RED)

                print()
                break

            else:
                print_color("Invalid option. Please choose y, n, r, or q.", Colors.RED)

    # Verification
    print_color("━" * 70, Colors.CYAN)
    print_color("\n=== Verification ===\n", Colors.BLUE)

    if dry_run:
        print_color("Dry-run complete! No files were copied.", Colors.MAGENTA)
        print_color(f"Would have copied: {copied_count} file(s)", Colors.BLUE)
        print_color("Run without -n flag to actually organize fonts.", Colors.BLUE)
    else:
        print_color("Font organization complete!\n", Colors.GREEN)

        # Count files
        source_count = len(font_files)
        dest_count = len([f for f in output_dir.rglob('*') if f.is_file()])
        dest_dirs = len([d for d in output_dir.rglob('*') if d.is_dir()])

        print_color("Source directory:", Colors.BLUE)
        print(f"  Path:  {Colors.CYAN}{font_dir}{Colors.NC}")
        print(f"  Fonts: {Colors.CYAN}{source_count}{Colors.NC} file(s)")
        print()
        print_color("Destination directory:", Colors.BLUE)
        print(f"  Path:  {Colors.CYAN}{output_dir}{Colors.NC}")
        print(f"  Fonts: {Colors.CYAN}{dest_count}{Colors.NC} file(s)")
        print(f"  Subdirectories created: {Colors.CYAN}{dest_dirs}{Colors.NC}")
        print()

        # Verify counts
        if dest_count == copied_count:
            print_color("✓ Verification passed!", Colors.GREEN)
            print(f"  All {copied_count} copied file(s) are present in destination.")
        else:
            print_color("✗ Warning: Mismatch detected!", Colors.RED)
            print(f"  Expected {copied_count} file(s), found {dest_count} in destination.")

        # Show directory structure
        print_color("\nOrganized directory structure:", Colors.BLUE)
        if shutil.which('tree'):
            result = subprocess.run(['tree', '-L', '2', str(output_dir)],
                                   capture_output=True, text=True)
            lines = result.stdout.split('\n')[:35]
            print('\n'.join(lines))
            if len(result.stdout.split('\n')) > 35:
                print(f"  ... (truncated, use 'tree {output_dir}' to see full structure)")
        else:
            dirs = sorted([d.relative_to(output_dir) for d in output_dir.iterdir() if d.is_dir()])
            for d in dirs[:20]:
                # Show a few files in each directory
                dir_path = output_dir / d
                files = sorted([f.name for f in dir_path.iterdir() if f.is_file()])
                print(f"  {d}/")
                for file in files[:3]:
                    print(f"    - {file}")
                if len(files) > 3:
                    print(f"    - ... ({len(files) - 3} more)")
            if len(dirs) > 20:
                print("  ... (truncated)")
            print_color("\nTip: Install 'tree' for better directory visualization", Colors.YELLOW)

        print_color("\nNext steps:", Colors.BLUE)
        print(f"  1. Review the organized fonts in: {Colors.CYAN}{output_dir}{Colors.NC}")
        print(f"  2. Copy to {Colors.CYAN}~/.local/share/fonts/{Colors.NC} (user) or {Colors.CYAN}/usr/share/fonts/{Colors.NC} (system):")
        print(f"     {Colors.CYAN}cp -r {output_dir}/* ~/.local/share/fonts/{Colors.NC}")
        print(f"  3. Run: {Colors.CYAN}fc-cache -fv{Colors.NC}")

def main():
    parser = argparse.ArgumentParser(
        description='Organize fonts according to Fedora font guidelines with normalized filenames',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -n fonts/                    # Preview, output to organized-fonts/
  %(prog)s fonts/                       # Organize fonts/ to organized-fonts/
  %(prog)s -o my-fonts fonts/           # Organize fonts/ to my-fonts/
  %(prog)s -d fonts/                    # Debug mode with detailed output

Font naming convention:
  - Regular fonts: <FontName>-<Style>.ext (e.g., NotoSans-Bold.ttf)
  - Variable fonts: <FontName>[axes].ext (e.g., NotoSans[wght,wdth].ttf)
  Both font names and styles are normalized to PascalCase.

  Example transformations:
    "Foo BartR.ttf" → "FooBar-Regular.ttf"
    "noto sans bold italic.otf" → "NotoSans-BoldItalic.otf"
    "Roboto VF.ttf" (variable) → "Roboto[wght].ttf"
    "Inter Variable.ttf" → "Inter[ital,opsz,slnt,wght].ttf"

Requirements:
  - python3-fonttools (recommended, for accurate font detection)
  - fontconfig (optional, provides fc-query)
        """
    )

    parser.add_argument('source_dir',
                       type=str,
                       help='Source directory containing font files')
    parser.add_argument('-n', '--dry-run',
                       action='store_true',
                       help='Preview changes without copying files')
    parser.add_argument('-o', '--output',
                       type=str,
                       help='Specify output directory (default: organized-<source>)')
    parser.add_argument('-d', '--debug',
                       action='store_true',
                       help='Enable debug output')

    args = parser.parse_args()

    # Process paths
    source_dir = Path(args.source_dir).resolve()

    if not source_dir.exists():
        print_color(f"Error: Source directory does not exist: {source_dir}", Colors.RED)
        sys.exit(1)

    if not source_dir.is_dir():
        print_color(f"Error: Source path is not a directory: {source_dir}", Colors.RED)
        sys.exit(1)

    # Determine output directory
    if args.output:
        output_dir = Path(args.output).resolve()
    else:
        output_dir = source_dir.parent / f"organized-{source_dir.name}"

    try:
        organize_fonts(source_dir, output_dir, args.dry_run, args.debug)
    except KeyboardInterrupt:
        print_color("\n\nInterrupted by user", Colors.RED)
        sys.exit(130)

if __name__ == '__main__':
    main()
