import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/domain/entities/menu_info/menu_info.dart';
import 'package:flowhub/presentation/widgets/dashed_line_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Props data class for [OrderLabelWidget].
/// Encapsulates all data required to render a printed order label.
class OrderLabelWidgetProps {
  final String orderNo;
  final String sequence;
  final String totalSequence;
  final List<String> menus;
  final String qrData;
  final List<MenuIngredient> ingredients;
  final String version;
  final String temp;

  const OrderLabelWidgetProps({
    required this.orderNo,
    this.sequence = '01',
    this.totalSequence = '01',
    required this.menus,
    required this.qrData,
    this.ingredients = const [],
    this.version = '',
    this.temp = '',
  });
}

/// Renders a 384px-wide thermal printer label for a single order item.
class OrderLabelWidget extends StatelessWidget {
  final OrderLabelWidgetProps props;

  const OrderLabelWidget({super.key, required this.props});

  /// CSS `text-transform: capitalize` — uppercases only each word's first
  /// letter, leaving the rest of the word untouched (unlike capitalize-and-
  /// lowercase-rest, which would wrongly turn an already-correct abbreviation
  /// like "ESP" into "Esp").
  static String _capitalizeWords(String text) => text
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final String currentTime = DateTime.now().toString().substring(0, 19);
    final bool hasOptions = props.ingredients.isNotEmpty;

    return Container(
      width: 384,
      color: Colors.white,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column: rotated order number + sequence
            Container(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 40.0,
                right: 10.0,
              ),
              alignment: Alignment.topCenter,
              child: RotatedBox(
                quarterTurns: 3,
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.labelTitle,
                    children: [
                      TextSpan(text: props.orderNo),
                      TextSpan(
                        text: '.${props.sequence}/${props.totalSequence}',
                        style: AppTextStyles.labelTitle,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center: vertical dashed divider — sits 20 from the QR column.
            const DashedLineWidget(),

            const SizedBox(width: 20.0),

            // Right column: QR code + product info + footer
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 112.0,
                    height: 112.0,
                    child: QrImageView(
                      data: props.qrData.isNotEmpty ? props.qrData : props.orderNo,
                      size: 112.0,
                      padding: EdgeInsets.zero,
                      gapless: false,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    '[PRODUCT]',
                    style: AppTextStyles.labelSectionHeader,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _capitalizeWords(props.menus.isNotEmpty ? props.menus.first : '-'),
                    style: AppTextStyles.labelMenuName,
                  ),
                  if (props.temp.isNotEmpty) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      _capitalizeWords(props.temp),
                      style: AppTextStyles.labelProduct,
                    ),
                  ],
                  const SizedBox(height: 2.0),
                  Text(
                    'Version: ${props.version}',
                    style: AppTextStyles.labelProduct,
                  ),
                  if (hasOptions) ...[
                    const SizedBox(height: 16.0),
                    const Text(
                      '[OPTION]',
                      style: AppTextStyles.labelSectionHeader,
                    ),
                    const SizedBox(height: 4.0),
                    ...props.ingredients.map(
                      (ingredient) => Text(
                        _capitalizeWords('- ${ingredient.name}: ${ingredient.amount}'),
                        style: AppTextStyles.labelProduct,
                      ),
                    ),
                  ],
                  // 32 from options' last line (or from Version, if there are
                  // no options — either way it's always the previous Column
                  // child), matching both reference images.
                  const SizedBox(height: 32.0),
                  Text(
                    'ORDER TIME: $currentTime',
                    style: AppTextStyles.labelFooter,
                  ),
                  const Text(
                    'BUILD BY CAFE.BETA OS',
                    style: AppTextStyles.labelFooter,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
