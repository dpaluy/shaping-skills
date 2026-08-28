import { readFileSync, readdirSync, lstatSync } from "node:fs";
import { join, relative } from "node:path";

const repoRoot = process.cwd();
const canonicalRoot = join(repoRoot, "skills");
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

const canonicalSkills = skillNames(canonicalRoot);
const pluginSkills = skillNames(pluginSkillsRoot);
if (JSON.stringify(pluginSkills) !== JSON.stringify(canonicalSkills)) {
  throw new Error(
    `Codex plugin skills differ from canonical skills: expected ${canonicalSkills.join(", ")}; got ${pluginSkills.join(", ")}`,
  );
}

for (const skill of canonicalSkills) {
  const canonicalSkill = join(canonicalRoot, skill);
  const pluginSkill = join(pluginSkillsRoot, skill);
  const canonicalFiles = files(canonicalSkill);
  const pluginFiles = files(pluginSkill);
  if (JSON.stringify(pluginFiles) !== JSON.stringify(canonicalFiles)) {
    throw new Error(`Codex plugin file list is stale for skill: ${skill}`);
  }
  for (const file of canonicalFiles) {
    const canonical = readFileSync(join(canonicalSkill, file));
    const packaged = readFileSync(join(pluginSkill, file));
    if (!canonical.equals(packaged)) {
      throw new Error(`Codex plugin file is stale: ${join(skill, file)}`);
    }
  }
}

console.log(`Codex plugin valid; ${pluginSkills.length} materialized skills match canonical sources.`);
