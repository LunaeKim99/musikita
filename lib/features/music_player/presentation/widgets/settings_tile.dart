import 'package:flutter/material.dart';

enum SettingsTileType {
  navigation,
  toggle,
  slider,
  dropdown,
  action,
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final SettingsTileType type;
  final VoidCallback? onTap;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final double? sliderValue;
  final double minSlider;
  final double maxSlider;
  final int? sliderDivisions;
  final ValueChanged<double>? onSliderChanged;
  final VoidCallback? onSliderChangeEnd;
  final String? sliderLabel;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final ValueChanged<String?>? onDropdownChanged;
  final Widget? trailing;
  final bool enabled;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.type = SettingsTileType.navigation,
    this.onTap,
    this.toggleValue,
    this.onToggle,
    this.sliderValue,
    this.minSlider = 0.0,
    this.maxSlider = 1.0,
    this.sliderDivisions,
    this.onSliderChanged,
    this.onSliderChangeEnd,
    this.sliderLabel,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
    this.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (type == SettingsTileType.slider) {
      return _buildSliderTile(context);
    }

    return ListTile(
      onTap: enabled ? onTap : null,
      leading: icon != null
          ? Icon(
              icon,
              color: enabled ? null : Theme.of(context).colorScheme.outline,
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : Theme.of(context).colorScheme.outline,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: _buildTrailing(context),
      enabled: enabled,
    );
  }

  Widget _buildSliderTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    if (subtitle != null || sliderLabel != null)
                      Text(
                        subtitle ?? sliderLabel ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (sliderLabel != null)
                Text(
                  sliderLabel!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
            ],
          ),
          Slider(
            min: minSlider,
            max: maxSlider,
            divisions: sliderDivisions,
            value: sliderValue ?? minSlider,
            onChanged: enabled ? onSliderChanged : null,
            onChangeEnd: (v) {
              onSliderChangeEnd?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    if (trailing != null) return trailing;

    switch (type) {
      case SettingsTileType.toggle:
        return Switch(
          value: toggleValue ?? false,
          onChanged: enabled ? onToggle : null,
        );
      case SettingsTileType.dropdown:
        return DropdownButton<String>(
          value: dropdownValue,
          items: dropdownItems?.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: enabled ? onDropdownChanged : null,
          underline: const SizedBox.shrink(),
        );
      case SettingsTileType.navigation:
        return const Icon(Icons.chevron_right);
      case SettingsTileType.action:
        return Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
        );
      default:
        return null;
    }
  }
}
