import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/consts/const.dart';
import '../blocs/image_save_cubit.dart';
import '../blocs/image_save_state.dart';

Future<void> showImageBottomSheet({
  required BuildContext context,
  required String url,
}) async {

  await showModalBottomSheet(
    backgroundColor: Colors.black.withOpacity(0.3),
    barrierColor: Colors.black54,
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.98, // gần full screen
        alignment: Alignment.center,
        child: BlocProvider(
          create:(_) => GetIt.instance<ImageSaveCubit>(),
            child: _ImageViewerSheet(url: url)),
      );

    },
  );
}

class _ImageViewerSheet extends StatelessWidget {
  final String url;

  const _ImageViewerSheet({required this.url});

  @override
  Widget build(BuildContext context) {


    return BlocListener<ImageSaveCubit, ImageSaveState>(

      listener: (context, state) {
        if (state.status == ImageSaveStatus.saving) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }else if (state.status == ImageSaveStatus.success) {
          showMessageSnackBar(context, 'Lưu ảnh thành công');
          Navigator.of(context).pop();
        } else if (state.status == ImageSaveStatus.failure) {
          showMessageSnackBar(context, state.errorMessage ?? 'Lưu ảnh thất bại');
          Navigator.of(context).pop();
        }
      },
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: 40,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Hero(
                tag: url,
                child: InteractiveViewer(
                  maxScale: 5,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const CupertinoActivityIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Đóng',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Chia sẻ (tự cài đặt)',
                    onPressed: () {

                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                  IconButton(
                    tooltip: 'Tải xuống ',
                    onPressed: () {
                      context.read<ImageSaveCubit>().saveImage(url);
                    },
                    icon: const Icon(Icons.download, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
