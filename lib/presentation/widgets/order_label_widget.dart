import 'package:flutter/material.dart';
import 'package:kds/core/theme/app_theme.dart';
import 'package:kds/domain/entities/menu_recipe/menu_recipe.dart';
import 'package:kds/presentation/widgets/dashed_line_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Props data class for [OrderLabelWidget].
/// Encapsulates all data required to render a printed order label.
class OrderLabelWidgetProps {
  final String orderNo;
  final String sequence;
  final String totalSequence;
  final List<String> menus;
  final String qrData;
  final MenuRecipe? recipe;
  final String dispenserData;

  const OrderLabelWidgetProps({
    required this.orderNo,
    this.sequence = '01',
    this.totalSequence = '01',
    required this.menus,
    required this.qrData,
    this.recipe,
    this.dispenserData = 'N:0',
  });
}

/// Renders a 384px-wide thermal printer label for a single order item.
class OrderLabelWidget extends StatelessWidget {
  final OrderLabelWidgetProps props;

  const OrderLabelWidget({super.key, required this.props});

  @override
  Widget build(BuildContext context) {
    final String currentTime = DateTime.now().toString().substring(0, 19);

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
              padding: const EdgeInsets.only(left: 4.0, top: 12.0, right: 12.0),
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

            // Center: vertical dashed divider
            const DashedLineWidget(),

            const SizedBox(width: 12),

            // Right column: QR code + product info + footer
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120.0,
                    height: 120.0,
                    child: QrImageView(
                      data: props.qrData.isNotEmpty ? props.qrData : props.orderNo,
                      size: 120.0,
                      padding: EdgeInsets.zero,
                      gapless: false,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '[PRODUCT]',
                    style: AppTextStyles.labelProduct.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    props.menus.isNotEmpty ? props.menus.first : '-',
                    style: AppTextStyles.labelProduct.copyWith(fontSize: 20),
                  ),
                  Text(
                    'Version: 0.94.0506.02',
                    style: AppTextStyles.labelProduct.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  if (props.recipe != null) ...[
                    Text(
                      '[OPTION]',
                      style: AppTextStyles.labelProduct.copyWith(fontWeight: FontWeight.w700),
                    ),
                    ...props.recipe!.optionLines.map(
                      (line) => Text(
                        line,
                        style: AppTextStyles.labelProduct.copyWith(fontSize: 20),
                      ),
                    ),
                    if (props.dispenserData.isNotEmpty && props.dispenserData != 'N:0') ...[
                      () {
                        final parts = props.dispenserData.split(':');
                        if (parts.length == 2) {
                          final name = parts[0].replaceAll('_', ' ').toUpperCase();
                          return Text(
                            '- $name: ${parts[1]}g',
                            style: AppTextStyles.labelProduct.copyWith(fontSize: 20),
                          );
                        }
                        return const SizedBox.shrink();
                      }(),
                    ],
                  ],
                  const SizedBox(height: 36),
                  Text('ORDER TIME: $currentTime', style: AppTextStyles.labelFooter),
                  const Text('BUILD BY CAFE.BETA OS', style: AppTextStyles.labelFooter),
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
