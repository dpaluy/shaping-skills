import { readFileSync, readdirSync, lstatSync } from "node:fs";
import { join, relative } from "node:path";

const repoRoot = process.cwd();
const pluginRoot = join(repoRoot, "plugins", "shaping-skills");
const pluginSkillsRoot = join(pluginRoot, "skills");

const manifest = JSON.parse(
  readFileSync(join(pluginRoot, ".codex-plugin", "plugin.json"), "utf8"),
);
const marketplace = JSON.parse(
  readFileSync(join(repoRoot, ".agents", "plugins", "marketplace.json"), "utf8"),
);

if (manifest.name !== "shaping-skills" || manifest.skills !== "./skills/") {
  throw new Error("Codex plugin manifest does not identify the expected skills directory");
}

const entry = marketplace.plugins.find(({ name }) => name === manifest.name);
if (entry?.source?.source !== "local" || entry.source.path !== "./plugins/shaping-skills") {
  throw new Error("Codex marketplace does not point to the shaping-skills plugin");
}

function skillNames(root) {
  return readdirSync(root, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .filter((entry) => {
      try {
        return lstatSync(join(root, entry.name, "SKILL.md")).isFile();
      } catch {
        return false;
      }
    })
    .map(({ name }) => name)
    .sort();
}

function files(root, current = root) {
  const result = [];
  for (const entry of readdirSync(current, { withFileTypes: true })) {
    const path = join(current, entry.name);
    if (entry.isSymbolicLink()) {
      throw new Error(`Codex plugin contains unsupported symlink: ${relative(repoRoot, path)}`);
    }
    if (entry.isDirectory()) result.push(...files(root, path));
    if (entry.isFile()) result.push(relative(root, path));
  }
  return result.sort();
}

const pluginSkills = skillNames(pluginSkillsRoot);
if (pluginSkills.length === 0) {
  throw new Error("Codex plugin contains no skills");
}

for (const skill of pluginSkills) files(join(pluginSkillsRoot, skill));

console.log(`Codex plugin valid; ${pluginSkills.length} canonical skills found.`);
