import Path from 'path';
import { isPackaged } from 'electron-is-packaged';

export const RESOURCES_PATH = isPackaged
  ? Path.join(process.resourcesPath, 'assets')
  : Path.join(__dirname, '../assets');

const getAssetPath = (...paths: string[]): string => {
  return Path.join(RESOURCES_PATH, ...paths);
};

export { RESOURCES_PATH as resources, getAssetPath as asset };
export default getAssetPath;
