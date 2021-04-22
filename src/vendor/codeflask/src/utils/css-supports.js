export function toCamelCase(cssProperty) {
  const property = cssProperty
    .split('-')
    .filter((word) => !!word)
    .map((word) => word[0].toUpperCase() + word.substr(1))
    .join('');

  return property[0].toLowerCase() + property.substr(1);
}

export function cssSupports(property, value) {
  if (typeof CSS !== 'undefined') {
    if ('supports' in CSS && typeof CSS.supports === 'function') {
      return CSS.supports(property, value);
    }
  }

  if (typeof document === 'undefined') {
    return false;
  }

  return toCamelCase(property) in document.body.style;
}
